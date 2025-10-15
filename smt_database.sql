CREATE DATABASE smts_db;
Use smts_db;
CREATE USER '202303305_user'@'localhost' IDENTIFIED BY '202303305@spu.ac.za';
GRANT ALL PRIVILEGES ON *.* TO '202303305_user'@'localhost';
FLUSH PRIVILEGES;

CREATE TABLE Login (
    Login_ID INT AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    User_role VARCHAR(15) NOT NULL,
    Created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
alter table Login
add column	Account_status varchar(50) not null default'Active';

create table Learner(
	Learner_ID int auto_increment primary key,
    Name varchar(30) not null,
    MidName varchar(30),
    Surname varchar(30) not null,
    DateOfBirth date not null,
    Age int not null,
    ScholName varchar(50) not null,
    Pickup_Location varchar(100) not null,
    Dropoff_Location varchar(100) not null,
    MedicalCondition varchar(255),
    Parent_ID int unique not null,
    foreign key (Parent_ID) references Parent(Parent_ID)
);

CREATE TABLE Parent(
    Parent_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Surname VARCHAR(30) NOT NULL,
    Phone_number VARCHAR(11) NOT NULL,
    Emergency_number VARCHAR(11) NOT NULL,
    Relationship varchar (15) not null,
    Login_ID INT UNIQUE NOT NULL,
    FOREIGN KEY (Login_ID) REFERENCES Login(Login_ID)
);

create table driver_registrations(
	Driver_ID int auto_increment primary key,
	Name varchar(30) not null,
    Surname varchar(50) not null,
    Phone_number varchar(11) not null,
    School_name varchar(30) not null,
    Time_morning time,
    Time_afternoon time,
    Charge_amount_R double,
    Login_ID int unique not null,
	FOREIGN KEY (Login_ID) REFERENCES Login(Login_ID)
);

CREATE TABLE Transport(
    Transport_ID INT AUTO_INCREMENT PRIMARY KEY,
    License_pdf LONGBLOB NOT NULL,
    pdf_name VARCHAR(255) NOT NULL,
    License_number VARCHAR(20) NOT NULL,
    Vehicle_make VARCHAR(50) NOT NULL,
    Vehicle_model VARCHAR(50) NOT NULL,
    Vehicle_year INT,
    Vehicle_registration VARCHAR(20) UNIQUE NOT NULL,
    Registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Driver_ID INT UNIQUE NOT NULL,
    FOREIGN KEY (Driver_ID) REFERENCES driver_registrations(Driver_ID)
);

drop table payment;
create table Payment(
	Payment_ID int auto_increment primary key,
    Driver_name varchar(50) not null,
    Driver_surname varchar(50) not null,
    Amount_R double not null,
    School_name varchar(50) not null,
    Reference varchar(50) not null,
    Paid_at timestamp default current_timestamp,
    Parent_ID int unique not null,
    Arrangement_ID int unique not null,
    foreign key (Arrangement_ID) references Arrangement(Arrangement_ID),
    foreign key (Parent_ID) references Parent(Parent_ID)
);
drop table arrangement;
CREATE TABLE Arrangement (
    Arrangement_ID INT AUTO_INCREMENT PRIMARY KEY,
    Driver_ID INT,
    Driver_Name VARCHAR(100),
    Driver_Surname VARCHAR(100),
    Parent_ID INT,
    Parent_Name VARCHAR(100),
    Parent_Surname VARCHAR(100),
    Learner_ID INT,
    Learner_Name VARCHAR(100),
    Learner_Surname VARCHAR(100),
    Pickup_Location VARCHAR(255),
    Dropoff_Location VARCHAR(255),
    Time_Morning TIME,
    Time_Afternoon TIME,
    School_Name VARCHAR(255),
    Arrangement_Date DATE,
    Status ENUM('Pending', 'Confirmed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (Driver_ID) REFERENCES driver_registrations(Driver_ID),
    FOREIGN KEY (Parent_ID) REFERENCES parent(Parent_ID),
    FOREIGN KEY (Learner_ID) REFERENCES learner(Learner_ID)
);
    
CREATE TABLE Reviews (
    Review_ID INT AUTO_INCREMENT PRIMARY KEY,
    Parent_Name VARCHAR(100) NOT NULL,
    Driver_Name VARCHAR(100) NOT NULL,
    Comment TEXT,
    Review_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS qr_check (
    Check_ID INT PRIMARY KEY AUTO_INCREMENT,
    Learner_ID INT NOT NULL,
    CheckingIn_time DATETIME,
    CheckingOut_time DATETIME,
    FOREIGN KEY (Learner_ID) REFERENCES learner(Learner_ID)
);

CREATE TABLE IF NOT EXISTS documents (
    doc_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    doc_type VARCHAR(100) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES driver_registrations(driver_id)
);

CREATE TABLE IF NOT EXISTS rejected_docs (
    reject_id INT AUTO_INCREMENT PRIMARY KEY,
    doc_id INT NOT NULL,
    rejected_on DATE NOT NULL,
    reason VARCHAR(255) NOT NULL,
    comment TEXT,
    FOREIGN KEY (doc_id) REFERENCES documents(doc_id)
);

CREATE TABLE IF NOT EXISTS driver_location (
    driver_id INT PRIMARY KEY,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES driver_registrations(driver_id)
);
drop table admin_accounts;
CREATE TABLE IF NOT EXISTS admin_accounts (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    username VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Login_ID INT UNIQUE,
    FOREIGN KEY (Login_ID) REFERENCES Login(Login_ID)
);
insert into admin_accounts(full_name,phone,username,Login_ID)
values('Kagiso Diale', '267-71-123-456', 'k.diale',7);

ALTER TABLE Parent
DROP FOREIGN KEY Parent_ibfk_1,
ADD CONSTRAINT fk_parent_login
FOREIGN KEY (Login_ID) REFERENCES Login(Login_ID)
ON DELETE CASCADE;

ALTER TABLE Learner
DROP FOREIGN KEY Learner_ibfk_1,
ADD CONSTRAINT fk_learner_parent
FOREIGN KEY (Parent_ID) REFERENCES Parent(Parent_ID)
ON DELETE CASCADE;

ALTER TABLE driver_registrations
DROP FOREIGN KEY driver_registrations_ibfk_1,
ADD CONSTRAINT fk_driver_login
FOREIGN KEY (Login_ID) REFERENCES Login(Login_ID)
ON DELETE CASCADE;

ALTER TABLE Transport
DROP FOREIGN KEY Transport_ibfk_1,
ADD CONSTRAINT fk_transport_driver
FOREIGN KEY (Driver_ID) REFERENCES driver_registrations(Driver_ID)
ON DELETE CASCADE;

ALTER TABLE documents
DROP FOREIGN KEY documents_ibfk_1,
ADD CONSTRAINT fk_documents_driver
FOREIGN KEY (driver_id) REFERENCES driver_registrations(driver_id)
ON DELETE CASCADE;

ALTER TABLE rejected_docs
DROP FOREIGN KEY rejected_docs_ibfk_1,
ADD CONSTRAINT fk_reject_doc
FOREIGN KEY (doc_id) REFERENCES documents(doc_id)
ON DELETE CASCADE;

ALTER TABLE driver_location
DROP FOREIGN KEY driver_location_ibfk_1,
ADD CONSTRAINT fk_driver_location
FOREIGN KEY (driver_id) REFERENCES driver_registrations(driver_id)
ON DELETE CASCADE;

ALTER TABLE admin_accounts
DROP FOREIGN KEY admin_accounts_ibfk_1,
ADD CONSTRAINT fk_admin_login
FOREIGN KEY (Login_ID) REFERENCES Login(Login_ID)
ON DELETE CASCADE;

ALTER TABLE Arrangement
DROP FOREIGN KEY Arrangement_ibfk_1,
DROP FOREIGN KEY Arrangement_ibfk_2,
DROP FOREIGN KEY Arrangement_ibfk_3,
ADD CONSTRAINT fk_arr_driver FOREIGN KEY (Driver_ID) REFERENCES driver_registrations(Driver_ID) ON DELETE CASCADE,
ADD CONSTRAINT fk_arr_parent FOREIGN KEY (Parent_ID) REFERENCES Parent(Parent_ID) ON DELETE CASCADE,
ADD CONSTRAINT fk_arr_learner FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID) ON DELETE CASCADE;

ALTER TABLE Payment
DROP FOREIGN KEY Payment_ibfk_1,
DROP FOREIGN KEY Payment_ibfk_2,
ADD CONSTRAINT fk_payment_parent FOREIGN KEY (Parent_ID) REFERENCES Parent(Parent_ID) ON DELETE CASCADE,
ADD CONSTRAINT fk_payment_arr FOREIGN KEY (Arrangement_ID) REFERENCES Arrangement(Arrangement_ID) ON DELETE CASCADE;

ALTER TABLE qr_check
DROP FOREIGN KEY qr_check_ibfk_1,
ADD CONSTRAINT fk_qr_learner
FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID)
ON DELETE CASCADE;



