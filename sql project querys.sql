--  Retail Banking Transaction Analysis   -----------


CREATE DATABASE retail_banking;
USE retail_banking;
-- =========================================================
-- customer table -------------

CREATE TABLE customers(
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(50),
    customer_since DATE,
    kyc_status VARCHAR(30),
    segment VARCHAR(30),
    annual_income DECIMAL(15,2),
    credit_score INT,
    is_active VARCHAR(10)
);
-- =========================================================
--  branches table ---


CREATE TABLE branches(
    branch_id VARCHAR(20) PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(50),
    region VARCHAR(50),
    opening_date DATE,
    employee_count INT
);
-- =========================================================

-- accounts table -----

CREATE TABLE accounts(
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    branch_id VARCHAR(20),
    account_type VARCHAR(50),
    open_date DATE,
    close_date DATE,
    current_balance DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    overdraft_limit DECIMAL(15,2),
    status VARCHAR(30),

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_accounts_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
);


-- =========================================================
--   CARDS TABLE

CREATE TABLE cards (
    card_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20),
    card_type VARCHAR(30),
    issue_date DATE,
    expiry_date DATE,
    credit_limit DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2),
    reward_points INT,
    is_active VARCHAR(10),
    network VARCHAR(30),

    CONSTRAINT fk_cards_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);
-- =========================================================
-- loan tables------
drop TABLE loans;
CREATE TABLE loans(
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    branch_id VARCHAR(20),
    loan_type VARCHAR(50),
    principal_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    tenure_months INT,
    disbursement_date DATE,
    maturity_date DATE,
    emi_amount DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2),
    loan_status VARCHAR(30),
    purpose VARCHAR(100),

    CONSTRAINT fk_loans_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_loans_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
);

-- =========================================================
-- loan_payments tables---


CREATE TABLE loan_payments(
    payment_id VARCHAR(20) PRIMARY KEY,
    loan_id VARCHAR(20),
    payment_date DATE,
    scheduled_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2),
    principal_paid DECIMAL(15,2),
    interest_paid DECIMAL(15,2),
    penalty DECIMAL(15,2),
    days_late INT,
    payment_method VARCHAR(50),
    status VARCHAR(30),

    CONSTRAINT fk_loan_payments_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);

-- =========================================================

-- transactions ---
CREATE TABLE transactions(
    transaction_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20),
    transaction_date DATE,
    transaction_time TIME,
    transaction_type VARCHAR(30),
    amount DECIMAL(15,2),
    channel VARCHAR(30),
    description VARCHAR(255),
    balance_after DECIMAL(15,2),
    status VARCHAR(30),

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);


SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'branches', COUNT(*) FROM branches
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'loans', COUNT(*) FROM loans
UNION ALL
SELECT 'loan_payments', COUNT(*) FROM loan_payments
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
;


-- this query become count for columns and columns name 
SELECT 
    TABLE_NAME,
    COUNT(*) AS column_count,
    GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'retail_banking'
GROUP BY TABLE_NAME;


-- combine no.of columns , columns name , count, each table rows count.

SELECT 
    c.TABLE_NAME AS table_name,
    t.TABLE_ROWS AS row_count,
    COUNT(c.COLUMN_NAME) AS column_count,
    GROUP_CONCAT(
        c.COLUMN_NAME 
        ORDER BY c.ORDINAL_POSITION
    ) AS columns
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.TABLES t
    ON c.TABLE_SCHEMA = t.TABLE_SCHEMA
    AND c.TABLE_NAME = t.TABLE_NAME
WHERE c.TABLE_SCHEMA = 'retail_banking'
GROUP BY 
    c.TABLE_NAME,
    t.TABLE_ROWS
ORDER BY c.TABLE_NAME;

-- ========================================================================= -- 
-- Basic Analysis / Data Exploration --
-- 1. what is the total numbers of customers?
select count(*) from customers;

-- 2.What is the total number of accounts?
select count(*) from accounts;

-- 3.What are the different account types available?

SELECT distinct
    account_type,
    COUNT(*) AS account_count
FROM accounts
GROUP BY account_type;


-- 4.How many customers are currently active?

select * from customers
where is_active = 'Yes';

-- Or ----
select customer_id,is_active from customers
where is_active = 'Yes' 
group by customer_id, is_active;

-- 5.What are the different transaction types available?

SELECT 
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type; 
-- 6.What is the total amount of completed transactions?

SELECT status,
    SUM(amount) AS total_amount
FROM transactions
WHERE status = 'Completed'
group by status ;

-- 7.What are the different loan types available?

select distinct loan_type , count(*) as total_count from 
loans group by loan_type;

-- 8.What is the total number of loans

SELECT COUNT(*) AS total_loans
FROM loans;

-- 9.What are the different card types available?

select distinct card_type ,count(*) as total_card from 
cards group by card_type;

-- 10.What is the total outstanding loan balance?

SELECT 
    SUM(outstanding_balance) AS total_outstanding_loan_balance
FROM loans;

-- ===================================================================== --

-- Sprint 4: Objective-Based Analysis


-- 4.1 Understand Customer Profile and Segmentation
-- Business Objective: The bank wants to understand its customer base and identify differences between
-- customer groups.

-- 1. Compare customers across different segments.
select segment,count(*) as customer_count
from customers
group by segment 
order by customer_count desc;

-- 2. Look at customer demographics.
-- What is the average annual income and credit score by customer segment?
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(AVG(annual_income), 2) AS avg_annual_income,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM customers
GROUP BY segment
ORDER BY avg_annual_income DESC;

-- 3. Compare customers across cities and states.
-- Which states have the highest number of customers?
-- states compresion
SELECT
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

-- city wise compresion

SELECT
    city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;

-- City within state compresion

SELECT
    state,
    city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state, city
ORDER BY customer_count DESC;

-- 4. Examine income and credit-score differences.
-- Which segment has the highest and lowest annual income?
SELECT
    segment,
    ROUND(MIN(annual_income), 2) AS min_income,
    ROUND(AVG(annual_income), 2) AS avg_income,
    ROUND(MAX(annual_income), 2) AS max_income
FROM customers
GROUP BY segment
ORDER BY avg_income DESC;

--  How does credit-score range differ across segments?
SELECT
    segment,
    MIN(credit_score) AS min_credit_score,
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    MAX(credit_score) AS max_credit_score
FROM customers
GROUP BY segment
ORDER BY avg_credit_score DESC;


-- What is the average annual income and credit score by customer segment?
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(AVG(annual_income), 2) AS avg_annual_income,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM customers
GROUP BY segment
ORDER BY avg_annual_income DESC;


-- 5. Look at customer activity and KYC status.

-- What is the distribution of customers by KYC status?

SELECT
    kyc_status,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY kyc_status
ORDER BY customer_count DESC;

-- What is the distribution of active and inactive customers
SELECT
    is_active,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers),
        2
    ) AS percentage
FROM customers
GROUP BY is_active
ORDER BY customer_count DESC;
-- 

-- 6. Understand customer tenure with the bank.

-- What is the average customer tenure by segment?

SELECT
    c.segment,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                YEAR,
                c.customer_since,
                (SELECT MAX(transaction_date) FROM transactions)
            )
        ), 2
    ) AS avg_tenure_years
FROM customers c
GROUP BY c.segment
ORDER BY avg_tenure_years DESC;

-- 4.2 Understand Account Usage and Branch Activity
-- Business Objective: The bank wants to understand how its accounts are being used and how account
-- activity differs across account types and branches.

-- 1.Compare different account types.

-- How many accounts are there for each account type?

SELECT
    account_type,
    COUNT(*) AS account_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM accounts),
        2
    ) AS percentage
FROM accounts
GROUP BY account_type
ORDER BY account_count DESC;


-- 2.Compare account activity across customers.
SELECT
    customer_id,
    COUNT(*) AS account_count,
    ROUND(SUM(current_balance), 2) AS total_balance,
    ROUND(AVG(current_balance), 2) AS avg_balance
FROM accounts
GROUP BY customer_id
ORDER BY total_balance DESC;

-- 3.Examine account balances.

SELECT
    account_type,
    COUNT(*) AS account_count,
    ROUND(MIN(current_balance), 2) AS min_balance,
    ROUND(AVG(current_balance), 2) AS avg_balance,
    ROUND(MAX(current_balance), 2) AS max_balance,
    ROUND(SUM(current_balance), 2) AS total_balance
FROM accounts
GROUP BY account_type
ORDER BY total_balance DESC;

-- 4.Compare account activity across branches.

SELECT
    branch_id,
    COUNT(*) AS account_count
FROM accounts
GROUP BY branch_id
ORDER BY account_count DESC;

-- 5.Compare account types across branches

SELECT
    branch_id,
    account_type,
    COUNT(*) AS account_count
FROM accounts
GROUP BY branch_id, account_type
ORDER BY branch_id, account_count DESC;

-- 6.Look at interest rates across account types.

SELECT
    account_type,
    ROUND(MIN(interest_rate), 2) AS min_interest_rate,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(MAX(interest_rate), 2) AS max_interest_rate
FROM accounts
GROUP BY account_type
ORDER BY avg_interest_rate DESC;

-- 7.Identify differences between active and closed accounts.

SELECT
    status,
    COUNT(*) AS account_count,
    ROUND(AVG(current_balance), 2) AS avg_balance,
    ROUND(sum(current_balance), 2) AS total_balance
FROM accounts
GROUP BY status
ORDER BY account_count DESC;

-- 8. Active vs closed accounts by account type

SELECT
    account_type,
    status,
    COUNT(*) AS account_count
FROM accounts
GROUP BY account_type, status
ORDER BY account_type, account_count DESC;

-- 4.3 Analyze Transaction Patterns
-- Business Objective: The bank wants to understand how customers use their accounts and how money
-- moves through the banking system.


-- 1. Compare different transaction types.

-- How frequently does each transaction type occur, and what percentage of total transactions does each type represent?

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS percentage
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;
-- 2. Compare transactions across different channels.
-- How do transaction amounts differ across transaction types?

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(MIN(amount), 2) AS min_amount,
    ROUND(MAX(amount), 2) AS max_amount
FROM transactions
GROUP BY transaction_type
ORDER BY total_amount DESC;

-- 3.Examine transaction amounts.

-- Which transaction channels are used most frequently, and how much money is processed through each channel?

SELECT
    channel,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
GROUP BY channel
ORDER BY transaction_count DESC;

-- 4.Look at common transaction descriptions.
-- What are the most common transaction descriptions in the banking system?
SELECT
    description,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY description
ORDER BY transaction_count DESC;


-- top 10 description

SELECT
    description,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY description
ORDER BY transaction_count DESC
LIMIT 10;

-- 5.Examine transaction activity over time.

-- How does transaction activity vary over time?

SELECT
    transaction_date,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;

-- How does transaction volume and value change from month to month?

SELECT
    YEAR(transaction_date) AS transaction_year,
    MONTH(transaction_date) AS transaction_month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date)
ORDER BY
    transaction_year,
    transaction_month;

-- 6.Compare transaction activity across accounts or customer groups.

-- Which accounts have the highest transaction activity and transaction value?

SELECT
    account_id,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_transaction_amount
FROM transactions
GROUP BY account_id
ORDER BY transaction_count DESC;


-- 7.Look at how transaction activity affects account balances.

-- How does transaction activity differ across customer segments?

SELECT
    c.segment,
    COUNT(t.transaction_id) AS transaction_count,
    ROUND(SUM(t.amount), 2) AS total_amount,
    ROUND(AVG(t.amount), 2) AS avg_transaction_amount
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.segment
ORDER BY transaction_count DESC;


-- 4.4 Evaluate Loan Performance and Repayment Behaviour
-- Business Objective: The bank wants to understand how its loans are performing and whether
-- customers are repaying their loans as expected.

-- 1.Compare different loan types.
-- How are loans distributed across different loan types?

SELECT
    loan_type,
    COUNT(*) AS loan_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM loans),
        2
    ) AS percentage
FROM loans
GROUP BY loan_type
ORDER BY loan_count DESC;

-- How do loan amounts and outstanding balances differ across loan types?

SELECT
    loan_type,
    COUNT(*) AS loan_count,
    ROUND(SUM(principal_amount), 2) AS total_principal,
    ROUND(AVG(principal_amount), 2) AS avg_principal,
    ROUND(SUM(outstanding_balance), 2) AS total_outstanding,
    ROUND(AVG(outstanding_balance), 2) AS avg_outstanding
FROM loans
GROUP BY loan_type
ORDER BY total_principal DESC;

-- 2.Compare loans based on their purpose.

-- What are the most common purposes for which customers take loans?
SELECT
    purpose,
    COUNT(*) AS loan_count,
    ROUND(SUM(principal_amount), 2) AS total_loan_amount,
    ROUND(AVG(principal_amount), 2) AS avg_loan_amount
FROM loans
GROUP BY purpose
ORDER BY loan_count DESC;

-- 3.Examine loan amounts and outstanding balances.
-- Which loans have the highest outstanding balances?
SELECT
    loan_id,
    customer_id,
    loan_type,
    principal_amount,
    outstanding_balance,
    loan_status
FROM loans
ORDER BY outstanding_balance DESC
LIMIT 20;

-- 4.Compare loan statuses.
-- How are loans distributed across different loan statuses?

SELECT
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM loans),
        2
    ) AS percentage
FROM loans
GROUP BY loan_status
ORDER BY loan_count DESC;

-- 5.Identify loans with repayment delays.
-- How many loan payments were made late, and how many days late were they on average?
SELECT
    COUNT(*) AS late_payment_count,
    ROUND(AVG(days_late), 2) AS avg_days_late,
    MAX(days_late) AS max_days_late
FROM loan_payments
WHERE days_late > 0;

-- Which loans have the highest number of delayed payments?

SELECT
    loan_id,
    COUNT(*) AS late_payment_count,
    ROUND(AVG(days_late), 2) AS avg_days_late,
    MAX(days_late) AS max_days_late
FROM loan_payments
WHERE days_late > 0
GROUP BY loan_id
ORDER BY late_payment_count DESC;

-- 6.xamine penalties and late payments.
-- How much penalty has been charged, and which loans have incurred the highest penalties?

SELECT
    loan_id,
    COUNT(*) AS payment_count,
    ROUND(SUM(penalty), 2) AS total_penalty,
    ROUND(AVG(days_late), 2) AS avg_days_late
FROM loan_payments
WHERE penalty > 0
GROUP BY loan_id
ORDER BY total_penalty DESC;

-- Overall penalty analysis
-- How do late payments and penalties vary across loan types?

SELECT
    l.loan_type,
    COUNT(lp.payment_id) AS payment_count,
    SUM(CASE WHEN lp.days_late > 0 THEN 1 ELSE 0 END) AS late_payment_count,
    ROUND(SUM(lp.penalty), 2) AS total_penalty,
    ROUND(AVG(lp.days_late), 2) AS avg_days_late
FROM loans l
JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY l.loan_type
ORDER BY late_payment_count DESC;

-- 7.Compare repayment behaviour across loan types or branches.
-- How does repayment behaviour differ across branches?

SELECT
    l.branch_id,
    COUNT(lp.payment_id) AS payment_count,
    SUM(CASE WHEN lp.days_late > 0 THEN 1 ELSE 0 END) AS late_payment_count,
    ROUND(AVG(lp.days_late), 2) AS avg_days_late,
    ROUND(SUM(lp.penalty), 2) AS total_penalty
FROM loans l
JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY l.branch_id
ORDER BY late_payment_count DESC;

-- 8.Look at payment methods used by customers.
-- Which payment methods are most commonly used by customers for loan repayments?

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    lp.payment_method,
    COUNT(lp.payment_id) AS payment_count,
    ROUND(SUM(lp.paid_amount), 2) AS total_paid_amount
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    lp.payment_method
ORDER BY payment_count DESC;

-- 4.5 Understand Card Usage and Product Engagement
-- Business Objective: The bank wants to understand how customers use its card products and how card
-- usage relates to their broader banking relationship.

-- 1.Compare different card types.
-- How are cards distributed across different card types, and what percentage of total cards does each type represent?

SELECT
    card_type,
    COUNT(*) AS card_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM cards),
        2
    ) AS percentage
FROM cards
GROUP BY card_type
ORDER BY card_count DESC;

-- How many cards are associated with each customer through their accounts?
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(cd.card_id) AS card_count
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN cards cd
    ON a.account_id = cd.account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY card_count DESC;
-- 2.Examine credit limits and outstanding balances.

-- How do credit limits differ across different card types?

SELECT
    card_type,
    COUNT(*) AS card_count,
    ROUND(MIN(credit_limit), 2) AS min_credit_limit,
    ROUND(AVG(credit_limit), 2) AS avg_credit_limit,
    ROUND(MAX(credit_limit), 2) AS max_credit_limit
FROM cards
GROUP BY card_type
ORDER BY avg_credit_limit DESC;


-- 3.Compare active and inactive cards.

-- How are cards distributed between active and inactive statuses?

SELECT
    is_active,
    COUNT(*) AS card_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM cards),
        2
    ) AS percentage
FROM cards
GROUP BY is_active
ORDER BY card_count DESC;

-- 4.Examine reward points.

-- How do reward points vary across different card types?

SELECT
    card_type,
    COUNT(*) AS card_count,
    SUM(reward_points) AS total_reward_points,
    ROUND(AVG(reward_points), 2) AS avg_reward_points,
    MAX(reward_points) AS max_reward_points
FROM cards
GROUP BY card_type
ORDER BY avg_reward_points DESC;


-- Which customers have accumulated the highest reward points across their cards?

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(cd.reward_points) AS total_reward_points,
    COUNT(cd.card_id) AS card_count
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN cards cd
    ON a.account_id = cd.account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_reward_points DESC;


 -- 5.Compare card usage across accounts and networks.
 
 -- Which card networks are most commonly used by customers?
 SELECT
    network,
    COUNT(*) AS card_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM cards),
        2
    ) AS percentage
FROM cards
GROUP BY network
ORDER BY card_count DESC;

-- How many cards are associated with each account, and what are their outstanding balances?

SELECT
    a.account_id,
    a.customer_id,
    COUNT(cd.card_id) AS card_count,
    ROUND(SUM(cd.outstanding_balance), 2) AS total_card_outstanding,
    ROUND(AVG(cd.outstanding_balance), 2) AS avg_card_outstanding
FROM accounts a
JOIN cards cd
    ON a.account_id = cd.account_id
GROUP BY
    a.account_id,
    a.customer_id
ORDER BY total_card_outstanding DESC;

-- 6.Identify customers using multiple banking products.
-- Which customers have multiple cards associated with their banking accounts?

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(cd.card_id) AS card_count
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN cards cd
    ON a.account_id = cd.account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(cd.card_id) > 1
ORDER BY card_count DESC;
-- How many different banking products does each customer have?

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT a.account_id) AS account_count,
    COUNT(DISTINCT cd.card_id) AS card_count,
    COUNT(DISTINCT l.loan_id) AS loan_count
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN cards cd
    ON a.account_id = cd.account_id
LEFT JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    account_count DESC,
    card_count DESC,
    loan_count DESC;
    
-- 7.Look at relationships between cards, accounts, and loans.

-- How does card ownership relate to loan ownership among customers?
SELECT
    COUNT(DISTINCT CASE
        WHEN cd.card_id IS NOT NULL
         AND l.loan_id IS NOT NULL
        THEN c.customer_id
    END) AS customers_with_cards_and_loans,

    COUNT(DISTINCT CASE
        WHEN cd.card_id IS NOT NULL
        THEN c.customer_id
    END) AS customers_with_cards,

    COUNT(DISTINCT CASE
        WHEN l.loan_id IS NOT NULL
        THEN c.customer_id
    END) AS customers_with_loans
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN cards cd
    ON a.account_id = cd.account_id
LEFT JOIN loans l
    ON c.customer_id = l.customer_id;
    


