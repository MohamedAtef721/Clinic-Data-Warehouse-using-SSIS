CREATE TABLE Dim_Patient (
    PatientKey INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    Name NVARCHAR(100),
    Gender NVARCHAR(10),
    Age INT,
    City NVARCHAR(50),
    EffectiveDate DATE,
    ExpiryDate DATE,
    IsCurrent BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

CREATE TABLE Dim_Doctor (
    DoctorKey INT IDENTITY(1,1) PRIMARY KEY,
    DoctorID INT NOT NULL,
    Name NVARCHAR(100),
    Specialty NVARCHAR(100),
    ExperienceYears INT,
    EffectiveDate DATE,
    ExpiryDate DATE,
    IsCurrent BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

CREATE TABLE Dim_Clinic (
    ClinicKey INT IDENTITY(1,1) PRIMARY KEY,
    ClinicID INT NOT NULL,
    ClinicName NVARCHAR(100),
    Location NVARCHAR(200),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME
);

CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Day INT,
    Month INT,
    Year INT,
    Quarter INT,
    DayOfWeek NVARCHAR(10),
    MonthName NVARCHAR(10),
    IsWeekend BIT
);

CREATE TABLE Dim_Diagnosis (
    DiagnosisKey INT IDENTITY(1,1) PRIMARY KEY,
    DiagnosisID INT NOT NULL,
    DiagnosisName NVARCHAR(200),
    Category NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Fact_Visits (
    VisitKey INT IDENTITY(1,1) PRIMARY KEY,
    VisitID INT NOT NULL,
    PatientKey INT NOT NULL,
    DoctorKey INT NOT NULL,
    ClinicKey INT NOT NULL,
    DateKey INT NOT NULL,
    DiagnosisKey INT NOT NULL,
    VisitCost DECIMAL(10,2),
    PaymentStatus NVARCHAR(20),
    LoadDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Fact_Patient FOREIGN KEY (PatientKey) REFERENCES Dim_Patient(PatientKey),
    CONSTRAINT FK_Fact_Doctor FOREIGN KEY (DoctorKey) REFERENCES Dim_Doctor(DoctorKey),
    CONSTRAINT FK_Fact_Clinic FOREIGN KEY (ClinicKey) REFERENCES Dim_Clinic(ClinicKey),
    CONSTRAINT FK_Fact_Date FOREIGN KEY (DateKey) REFERENCES Dim_Date(DateKey),
    CONSTRAINT FK_Fact_Diagnosis FOREIGN KEY (DiagnosisKey) REFERENCES Dim_Diagnosis(DiagnosisKey)
);

CREATE NONCLUSTERED INDEX IX_Fact_Visits_DateKey ON Fact_Visits(DateKey);
CREATE NONCLUSTERED INDEX IX_Fact_Visits_PatientKey ON Fact_Visits(PatientKey);
CREATE NONCLUSTERED INDEX IX_Fact_Visits_DoctorKey ON Fact_Visits(DoctorKey);