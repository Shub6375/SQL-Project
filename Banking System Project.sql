-- Create a Banking System Database
create database banking_system_project;

--Using the database
use banking_system_project;

--Create Table: Account Opening Form
create table account_opening_form (
[date] date default getdate(),
Account_type varchar(20) default 'saving',
Account_HolderName varchar(50),
DOB date,
AadharNumber varchar(12),
MobileNumber varchar(15),
Account_opening_balance decimal(10,2),
FullAddress varchar(100),
KYC_Status varchar(20) default 'pending'
);

--Create Table: Bank
create table bank(
AccountNumber bigint identity(1000000000,1),
AccountType varchar(20),
AccountOpeningDate date default getdate(),
CurrentBalance decimal(10,2)
);


--Create Table: AccountHolderDetail
create table AccountHolderDetail(
AccountNumber bigint identity(1000000000,1),
Account_HolderName varchar(50),
DOB date,
AadharNumber varchar(12),
MobileNumber varchar(15),
FullAddress varchar(100)
);


--Create Table: Transactional Detail
create table TransactionDetail(
AccountNumber bigint,
PaymentType varchar(20),
TransactionAmount decimal(10,2),
DateofTransaction date default getdate()
);

---UI insert value

Insert into account_opening_form 
(Account_type,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','Shubham','1999-08-24','545854562845','9875645565',1000,'UP');

--select* from account_opening_form
--creating trigger for insert data into two main tables (bank and Accountholderdetails)

create trigger dbo.insertdata
on account_opening_form
after update
as
declare @status varchar(20),
@Accout_type varchar(20),
@Account_HolderName varchar(50),
@DOB date,
@AadharNumber varchar(12),
@MobileNumber varchar(15),
@Account_opening_balance decimal(10,2),
@FullAddress varchar(100)

select @status=kyc_status , @Accout_type=Account_type, @Account_HolderName=Account_HolderName,
@DOB=dob, @AadharNumber= AadharNumber, @MobileNumber=MobileNumber, @Account_opening_balance=Account_opening_balance
,@FullAddress= FullAddress
from inserted

if @status='Approved'
begin

insert into bank (AccountType,CurrentBalance) values (@Accout_type,@Account_opening_balance)

insert into AccountHolderDetail(Account_HolderName,DOB,AadharNumber,MobileNumber,FullAddress)values
(@Account_HolderName,@DOB,@AadharNumber,@MobileNumber,@FullAddress)

end

--update status approved

update account_opening_form
set KYC_Status='Approved'
where AadharNumber='545854562845'

select* from bank;
select* from AccountHolderDetail;

--checking for rejected account status

Insert into account_opening_form 
(Account_type,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','shubham','1999-08-20','545854562887','9875645545',1000,'delhi');

select*from account_opening_form;


--update status Rejected

update account_opening_form
set KYC_Status='Rejected'
where AadharNumber='545854562887';


--create trigger on transaction table for update current balance into main table
select*from TransactionDetail;
select * from bank

create trigger dbo.updatecurrentbalance
on TransactionDetail
after insert
as
declare @paymenttype varchar(20),
@Amount decimal(10,2),
@accountnumber bigint

select @paymenttype=PaymentType, @Amount= TransactionAmount,
@accountnumber=AccountNumber
from inserted

if @paymenttype='credit'
begin
update bank
set CurrentBalance= CurrentBalance+@Amount
where AccountNumber=@accountnumber
end

if @paymenttype='debit'
begin
update bank
set CurrentBalance= CurrentBalance-@Amount
where AccountNumber=@accountnumber
end


--select*from bank
-- accountno 1000000000
select* from TransactionDetail


insert into TransactionDetail (AccountNumber,PaymentType,TransactionAmount) values
(1000000000,'credit',5000);


insert into TransactionDetail (AccountNumber,PaymentType,TransactionAmount) values
(1000000000,'debit',3000);

select* from TransactionDetail where DateofTransaction>= dateadd(month,-1,getdate())
and AccountNumber='1000000000';

select dateadd(month,-1,getdate());


--Create a Stored procedure for payment history
create Procedure dbo.paystatement( @month int, @accountnumber bigint)
as 
	begin
		select* from TransactionDetail where DateofTransaction>= dateadd(month,-1,getdate())
		and AccountNumber='1000000000';
end

exec dbo.paystatement 1, 1000000000
