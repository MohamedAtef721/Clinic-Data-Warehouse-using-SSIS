USE Clinic_DWH;
GO

DROP PROCEDURE IF EXISTS SP_Populate_Dim_Date;
GO

CREATE PROCEDURE SP_Populate_Dim_Date
    @StartDate DATE = '2020-01-01',
    @EndDate DATE = '2030-12-31'
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Dim_Date;
    
    DECLARE @CurrentDate DATE = @StartDate;
    
    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO Dim_Date (
            DateKey, FullDate, Day, Month, Year, Quarter,
            DayOfWeek, MonthName, IsWeekend
        )
        VALUES (
            CONVERT(INT, CONVERT(VARCHAR, @CurrentDate, 112)),
            @CurrentDate,
            DAY(@CurrentDate),
            MONTH(@CurrentDate),
            YEAR(@CurrentDate),
            DATEPART(QUARTER, @CurrentDate),
            DATENAME(WEEKDAY, @CurrentDate),
            DATENAME(MONTH, @CurrentDate),
            CASE 
                WHEN DATENAME(WEEKDAY, @CurrentDate) IN ('Saturday', 'Sunday') 
                THEN 1 ELSE 0 
            END
        );
        
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
    
    SELECT COUNT(*) AS TotalDates FROM Dim_Date;
END;
GO

EXEC SP_Populate_Dim_Date;
GO


--Stored Procedure  Dim_Patient

USE Clinic_DWH;
GO

CREATE PROCEDURE SP_Load_Dim_Patient
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Dim_Patient
    SET 
        ExpiryDate = GETDATE(),
        IsCurrent = 0,
        ModifiedDate = GETDATE()
    WHERE IsCurrent = 1
    AND PatientID IN (
        SELECT s.PatientID
        FROM Clinic_Staging.dbo.STG_Patients s
        INNER JOIN Dim_Patient d ON s.PatientID = d.PatientID
        WHERE d.IsCurrent = 1
        AND (
            s.Name <> d.Name OR
            s.Gender <> d.Gender OR
            s.Age <> d.Age OR
            s.City <> d.City
        )
    );
    
    INSERT INTO Dim_Patient (
        PatientID, Name, Gender, Age, City,
        EffectiveDate, ExpiryDate, IsCurrent
    )
    SELECT 
        s.PatientID, s.Name, s.Gender, s.Age, s.City,
        GETDATE(), '9999-12-31', 1
    FROM Clinic_Staging.dbo.STG_Patients s
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Dim_Patient d 
        WHERE d.PatientID = s.PatientID 
        AND d.IsCurrent = 1
        AND d.Name = s.Name
        AND d.Gender = s.Gender
        AND d.Age = s.Age
        AND d.City = s.City
    );
    
    SELECT COUNT(*) AS TotalPatients FROM Dim_Patient WHERE IsCurrent = 1;
END;
GO


-- Stored Procedure  Dim_Doctor
USE Clinic_DWH;
GO

CREATE PROCEDURE SP_Load_Dim_Doctor
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Dim_Doctor
    SET 
        ExpiryDate = GETDATE(),
        IsCurrent = 0,
        ModifiedDate = GETDATE()
    WHERE IsCurrent = 1
    AND DoctorID IN (
        SELECT s.DoctorID
        FROM Clinic_Staging.dbo.STG_Doctors s
        INNER JOIN Dim_Doctor d ON s.DoctorID = d.DoctorID
        WHERE d.IsCurrent = 1
        AND (
            s.Name <> d.Name OR
            s.Specialty <> d.Specialty OR
            s.ExperienceYears <> d.ExperienceYears
        )
    );
    
    INSERT INTO Dim_Doctor (
        DoctorID, Name, Specialty, ExperienceYears,
        EffectiveDate, ExpiryDate, IsCurrent
    )
    SELECT 
        s.DoctorID, s.Name, s.Specialty, s.ExperienceYears,
        GETDATE(), '9999-12-31', 1
    FROM Clinic_Staging.dbo.STG_Doctors s
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Dim_Doctor d 
        WHERE d.DoctorID = s.DoctorID 
        AND d.IsCurrent = 1
        AND d.Name = s.Name
        AND d.Specialty = s.Specialty
        AND d.ExperienceYears = s.ExperienceYears
    );
    
    SELECT COUNT(*) AS TotalDoctors FROM Dim_Doctor WHERE IsCurrent = 1;
END;
GO


-- Stored Procedure  Dim_Clinic

USE Clinic_DWH;
GO

CREATE PROCEDURE SP_Load_Dim_Clinic
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE d
    SET 
        d.ClinicName = s.ClinicName,
        d.Location = s.Location,
        d.ModifiedDate = GETDATE()
    FROM Dim_Clinic d
    INNER JOIN Clinic_Staging.dbo.STG_Clinics s ON d.ClinicID = s.ClinicID
    WHERE d.ClinicName <> s.ClinicName 
       OR d.Location <> s.Location;
    
    INSERT INTO Dim_Clinic (ClinicID, ClinicName, Location)
    SELECT s.ClinicID, s.ClinicName, s.Location
    FROM Clinic_Staging.dbo.STG_Clinics s
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Clinic d WHERE d.ClinicID = s.ClinicID
    );
    
    SELECT COUNT(*) AS TotalClinics FROM Dim_Clinic;
END;
GO

-- Stored Procedure  Dim_Diagnosis

USE Clinic_DWH;
GO

CREATE PROCEDURE SP_Load_Dim_Diagnosis
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE d
    SET 
        d.DiagnosisName = s.DiagnosisName,
        d.Category = s.Category
    FROM Dim_Diagnosis d
    INNER JOIN Clinic_Staging.dbo.STG_Diagnosis s ON d.DiagnosisID = s.DiagnosisID
    WHERE d.DiagnosisName <> s.DiagnosisName 
       OR d.Category <> s.Category;
    
    INSERT INTO Dim_Diagnosis (DiagnosisID, DiagnosisName, Category)
    SELECT s.DiagnosisID, s.DiagnosisName, s.Category
    FROM Clinic_Staging.dbo.STG_Diagnosis s
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Diagnosis d WHERE d.DiagnosisID = s.DiagnosisID
    );
    
    SELECT COUNT(*) AS TotalDiagnoses FROM Dim_Diagnosis;
END;
GO


-- Stored Procedure للـ Fact_Visits


USE Clinic_DWH;
GO

CREATE PROCEDURE SP_Load_Fact_Visits
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Fact_Visits (
        VisitID, PatientKey, DoctorKey, ClinicKey, 
        DateKey, DiagnosisKey, VisitCost, PaymentStatus
    )
    SELECT 
        v.VisitID,
        p.PatientKey,
        d.DoctorKey,
        c.ClinicKey,
        CONVERT(INT, CONVERT(VARCHAR, v.VisitDate, 112)) AS DateKey,
        diag.DiagnosisKey,
        v.VisitCost,
        v.PaymentStatus
    FROM Clinic_Staging.dbo.STG_Visits v
    INNER JOIN Dim_Patient p ON v.PatientID = p.PatientID AND p.IsCurrent = 1
    INNER JOIN Dim_Doctor d ON v.DoctorID = d.DoctorID AND d.IsCurrent = 1
    INNER JOIN Dim_Clinic c ON v.ClinicID = c.ClinicID
    INNER JOIN Dim_Diagnosis diag ON v.DiagnosisID = diag.DiagnosisID
    WHERE NOT EXISTS (
        SELECT 1 FROM Fact_Visits f WHERE f.VisitID = v.VisitID
    );
    
    SELECT COUNT(*) AS TotalVisits FROM Fact_Visits;
END;
GO



USE Clinic_DWH;
GO

CREATE PROCEDURE SP_Master_Load_DWH
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'Starting ETL Process...';
    PRINT '================================================';
    
    PRINT 'Loading Dim_Patient...';
    EXEC SP_Load_Dim_Patient;
    
    PRINT 'Loading Dim_Doctor...';
    EXEC SP_Load_Dim_Doctor;
    
    PRINT 'Loading Dim_Clinic...';
    EXEC SP_Load_Dim_Clinic;
    
    PRINT 'Loading Dim_Diagnosis...';
    EXEC SP_Load_Dim_Diagnosis;
    
    PRINT 'Loading Fact_Visits...';
    EXEC SP_Load_Fact_Visits;
    
    PRINT '================================================';
    PRINT 'ETL Process Completed Successfully!';
END;
GO

--