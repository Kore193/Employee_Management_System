CREATE DATABASE employee_management_system;
USE employee_management_system;
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?

select COUNT(*) as Unique_Employees
from Employee;

-- Which departments have the highest number of employees?

select j.JobDept, COUNT(*) AS Total_Employees
from Employee e
join JobDepartment j
on e.JobID = j.JobID
group by j.JobDept
order by Total_Employees DESC
limit 1;

-- What is the average salary per department?

select j.JobDept, avg(s.Amount) as Avg_Salary
from JobDepartment j
join Salary_Bonus s
on j.JobID = s.JobID
group by j.JobDept;

-- Who are the top 5 highest-paid employees?

select EmpID, TotalAmount
from Payroll
order by TotalAmount DESC
limit 5;

-- What is the total salary expenditure across the company?

select SUM(TotalAmount) as Total_Expenditure
from Payroll;


-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?

select JobDept, COUNT(*) as Total_Roles
from JobDepartment
group by JobDept;

-- What is the average salary range per department?

select jobdept,
avg(
    (cast(replace(substring_index(salaryrange, '-', 1), 'k', '000') as unsigned) +
     cast(replace(substring_index(salaryrange, '-', -1), 'k', '000') as unsigned)) / 2
) as avg_salary_range
from jobdepartment
group by jobdept;

-- Which job roles offer the highest salary?

select j.JobTilte, s.amount
from jobdepartment j
join salary_bonus s
on j.jobid = s.jobid
order by s.amount desc
limit 1;
select * from jobdepartment;

--  departments have the highest total salary allocation?

select j.jobdept, sum(s.amount) as total_salary
from jobdepartment j
join salary_bonus s
on j.jobid = s.jobid
group by j.jobdept
order by total_salary desc
limit 1;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?

select COUNT(distinct EmpID) AS Total_Employees_With_Qualification
from Qualification;

-- Which positions require the most qualifications?

select Position, COUNT(*) AS Total_Qualifications
from Qualification
group by Position
order by Total_Qualifications DESC;

-- Which employees have the highest number of qualifications?
select  EmpID, COUNT(QualID) as Total_Qualifications
from Qualification
group by EmpID
order by Total_Qualifications DESC
limit 1;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?

select year(date) as year, count(distinct empid) as total_employees
from leaves
group by year(date)
order by total_employees desc
limit 1;

-- What is the average number of leave days taken by its employees per department?

select j.jobdept, avg(l.leaveid) as avg_leaves
from leaves l
join employee e
 on l.empid = e.empid
join jobdepartment j 
on e.jobid = j.jobid
group by j.jobdept;

-- Which employees have taken the most leaves?

select empid, count(*) as total_leaves
from leaves
group by empid
order by total_leaves desc
limit 1;

-- What is the total number of leave days taken company-wide?

select count(*) as total_leave_days
from leaves;

-- How do leave days correlate with payroll amounts?

select p.empid, count(l.leaveid) as total_leaves, sum(p.totalamount) as total_salary
from payroll p
join leaves l 
on p.empid = l.empid
group by p.empid;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?

select  month(date) as month, 
sum(totalamount) as total_monthly_payroll
from payroll
group by month(date)
order by month;


-- What is the average bonus given per department?

select j.jobdept, avg(s.bonus) as avg_bonus
from salary_bonus s
join jobdepartment j on s.jobid = j.jobid
group by j.jobdept;

-- Which department receives the highest total bonuses?

select j.jobdept, sum(s.bonus) as total_bonus
from salary_bonus s
join jobdepartment j on s.jobid = j.jobid
group by j.jobdept
order by total_bonus desc
limit 1;

-- What is the average value of total_amount after considering leave deductions?

select avg(totalamount) as avg_total_amount
from payroll;

