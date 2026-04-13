--STG_Patients
CREATE TABLE STG_Patients (
    PatientID INT,
    Name NVARCHAR(100),
    Gender NVARCHAR(10),
    Age INT,
    City NVARCHAR(50),
    SourceSystem NVARCHAR(50),
    LoadDate DATETIME DEFAULT GETDATE()
);
--STG_Doctors
CREATE TABLE STG_Doctors (
    DoctorID INT,
    Name NVARCHAR(100),
    Specialty NVARCHAR(100),
    ExperienceYears INT,
    SourceSystem NVARCHAR(50),
    LoadDate DATETIME DEFAULT GETDATE()
);
--STG_Clinics
CREATE TABLE STG_Clinics (
    ClinicID INT,
    ClinicName NVARCHAR(100),
    Location NVARCHAR(200),
    SourceSystem NVARCHAR(50),
    LoadDate DATETIME DEFAULT GETDATE()
);
--STG_Visits
CREATE TABLE STG_Visits (
    VisitID INT,
    PatientID INT,
    DoctorID INT,
    ClinicID INT,
    DiagnosisID INT,
    VisitDate DATE,
    VisitCost DECIMAL(10,2),
    PaymentStatus NVARCHAR(20),
    SourceSystem NVARCHAR(50),
    LoadDate DATETIME DEFAULT GETDATE()
);
--STG_Diagnosis
CREATE TABLE STG_Diagnosis (
    DiagnosisID INT,
    DiagnosisName NVARCHAR(200),
    Category NVARCHAR(100),
    SourceSystem NVARCHAR(50),
    LoadDate DATETIME DEFAULT GETDATE()
);