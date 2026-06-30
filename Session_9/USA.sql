
CREATE DATABASE USA;
GO

USE USA;
GO

CREATE TABLE States
    (StateID INT PRIMARY KEY,
    StateName VARCHAR(20) NOT NULL,
    StateAbbreviation VARCHAR(2) NOT NULL,
    Region VARCHAR(10) NOT NULL );

INSERT INTO States (StateID, StateName, StateAbbreviation, Region)
VALUES
(1, 'Alabama', 'AL', 'South'),
(2, 'Alaska', 'AK', 'West'),
(3, 'Arizona', 'AZ', 'West'),
(4, 'Arkansas', 'AR', 'South'),
(5, 'California', 'CA', 'West'),
(6, 'Colorado', 'CO', 'West'),
(7, 'Connecticut', 'CT', 'Northeast'),
(8, 'Delaware', 'DE', 'South'),
(9, 'Florida', 'FL', 'South'),
(10, 'Georgia', 'GA', 'South'),
(11, 'Hawaii', 'HI', 'West'),
(12, 'Idaho', 'ID', 'West'),
(13, 'Illinois', 'IL', 'Midwest'),
(14, 'Indiana', 'IN', 'Midwest'),
(15, 'Iowa', 'IA', 'Midwest'),
(16, 'Kansas', 'KS', 'Midwest'),
(17, 'Kentucky', 'KY', 'South'),
(18, 'Louisiana', 'LA', 'South'),
(19, 'Maine', 'ME', 'Northeast'),
(20, 'Maryland', 'MD', 'South'),
(21, 'Massachusetts', 'MA', 'Northeast'),
(22, 'Michigan', 'MI', 'Midwest'),
(23, 'Minnesota', 'MN', 'Midwest'),
(24, 'Mississippi', 'MS', 'South'),
(25, 'Missouri', 'MO', 'Midwest'),
(26, 'Montana', 'MT', 'West'),
(27, 'Nebraska', 'NE', 'Midwest'),
(28, 'Nevada', 'NV', 'West'),
(29, 'New Hampshire', 'NH', 'Northeast'),
(30, 'New Jersey', 'NJ', 'Northeast'),
(31, 'New Mexico', 'NM', 'West'),
(32, 'New York', 'NY', 'Northeast'),
(33, 'North Carolina', 'NC', 'South'),
(34, 'North Dakota', 'ND', 'Midwest'),
(35, 'Ohio', 'OH', 'Midwest'),
(36, 'Oklahoma', 'OK', 'South'),
(37, 'Oregon', 'OR', 'West'),
(38, 'Pennsylvania', 'PA', 'Northeast'),
(39, 'Rhode Island', 'RI', 'Northeast'),
(40, 'South Carolina', 'SC', 'South'),
(41, 'South Dakota', 'SD', 'Midwest'),
(42, 'Tennessee', 'TN', 'South'),
(43, 'Texas', 'TX', 'South'),
(44, 'Utah', 'UT', 'West'),
(45, 'Vermont', 'VT', 'Northeast'),
(46, 'Virginia', 'VA', 'South'),
(47, 'Washington', 'WA', 'West'),
(48, 'West Virginia', 'WV', 'South'),
(49, 'Wisconsin', 'WI', 'Midwest'),
(50, 'Wyoming', 'WY', 'West');


CREATE TABLE Cities
    (CityID INT PRIMARY KEY,
    CityName VARCHAR(50) NOT NULL,
    StateID INT NOT NULL,
    FOREIGN KEY (StateID) REFERENCES States(StateID));

INSERT INTO Cities (CityID, CityName, StateID)
VALUES
(1, 'Birmingham', 1),
(2, 'Anchorage', 2),
(3, 'Phoenix', 3),
(4, 'Little Rock', 4),
(5, 'Los Angeles', 5),
(6, 'Denver', 6),
(7, 'Hartford', 7),
(8, 'Wilmington', 8),
(9, 'Miami', 9),
(10, 'Atlanta', 10),
(11, 'Honolulu', 11),
(12, 'Boise', 12),
(13, 'Chicago', 13),
(14, 'Indianapolis', 14),
(15, 'Des Moines', 15),
(16, 'Wichita', 16),
(17, 'Louisville', 17),
(18, 'New Orleans', 18),
(19, 'Portland', 19),
(20, 'Baltimore', 20),
(21, 'Boston', 21),
(22, 'Detroit', 22),
(23, 'Minneapolis', 23),
(24, 'Jackson', 24),
(25, 'Kansas City', 25),
(26, 'Billings', 26),
(27, 'Omaha', 27),
(28, 'Las Vegas', 28),
(29, 'Manchester', 29),
(30, 'Newark', 30),
(31, 'Albuquerque', 31),
(32, 'New York City', 32),
(33, 'Charlotte', 33),
(34, 'Fargo', 34),
(35, 'Columbus', 35),
(36, 'Oklahoma City', 36),
(37, 'Portland', 37),
(38, 'Philadelphia', 38),
(39, 'Providence', 39),
(40, 'Charleston', 40),
(41, 'Sioux Falls', 41),
(42, 'Nashville', 42),
(43, 'Houston', 43),
(44, 'Salt Lake City', 44),
(45, 'Burlington', 45),
(46, 'Virginia Beach', 46),
(47, 'Seattle', 47),
(48, 'Charleston', 48),
(49, 'Milwaukee', 49),
(50, 'Cheyenne', 50);


CREATE TABLE Landmarks
    (LandmarkID INT PRIMARY KEY,
    LandmarkName VARCHAR(100) NOT NULL,
    StateID INT NOT NULL,
    CityID INT NOT NULL,
    FOREIGN KEY (StateID) REFERENCES States(StateID),
    FOREIGN KEY (CityID) REFERENCES Cities(CityID));

INSERT INTO Landmarks (LandmarkID, LandmarkName, StateID, CityID)
VALUES
(1, 'Birmingham Civil Rights Institute', 1, 1),
(2, 'Anchorage Museum', 2, 2),
(3, 'Desert Botanical Garden', 3, 3),
(4, 'Little Rock Central High School', 4, 4),
(5, 'Hollywood Sign', 5, 5),
(6, 'Denver Union Station', 6, 6),
(7, 'Connecticut State Capitol', 7, 7),
(8, 'Grand Opera House', 8, 8),
(9, 'Vizcaya Museum and Gardens', 9, 9),
(10, 'Georgia Aquarium', 10, 10),
(11, 'Iolani Palace', 11, 11),
(12, 'Idaho State Capitol', 12, 12),
(13, 'Millennium Park', 13, 13),
(14, 'Soldiers and Sailors Monument', 14, 14),
(15, 'Iowa State Capitol', 15, 15),
(16, 'Keeper of the Plains', 16, 16),
(17, 'Louisville Slugger Museum', 17, 17),
(18, 'Jackson Square', 18, 18),
(19, 'Portland Head Light', 19, 19),
(20, 'Fort McHenry', 20, 20),
(21, 'Freedom Trail', 21, 21),
(22, 'Detroit Institute of Arts', 22, 22),
(23, 'Minneapolis Sculpture Garden', 23, 23),
(24, 'Mississippi State Capitol', 24, 24),
(25, 'National WWI Museum', 25, 25),
(26, 'Moss Mansion', 26, 26),
(27, 'Old Market', 27, 27),
(28, 'Las Vegas Strip', 28, 28),
(29, 'Currier Museum of Art', 29, 29),
(30, 'Branch Brook Park', 30, 30),
(31, 'Old Town Albuquerque', 31, 31),
(32, 'Statue of Liberty', 32, 32),
(33, 'NASCAR Hall of Fame', 33, 33),
(34, 'Fargo Theatre', 34, 34),
(35, 'Ohio Statehouse', 35, 35),
(36, 'Oklahoma City National Memorial', 36, 36),
(37, 'Pittock Mansion', 37, 37),
(38, 'Liberty Bell', 38, 38),
(39, 'Rhode Island State House', 39, 39),
(40, 'Rainbow Row', 40, 40),
(41, 'Falls Park', 41, 41),
(42, 'Ryman Auditorium', 42, 42),
(43, 'Space Center Houston', 43, 43),
(44, 'Temple Square', 44, 44),
(45, 'Church Street Marketplace', 45, 45),
(46, 'Virginia Beach Boardwalk', 46, 46),
(47, 'Space Needle', 47, 47),
(48, 'West Virginia State Capitol', 48, 48),
(49, 'Milwaukee Art Museum', 49, 49),
(50, 'Wyoming State Capitol', 50, 50);


CREATE TABLE Universities
    (UniversityID INT PRIMARY KEY,
    UniversityName VARCHAR(100) NOT NULL,
    UniversityType VARCHAR(20) NOT NULL,
    StateID INT NOT NULL,
    CityID INT NOT NULL,
    FOREIGN KEY (StateID) REFERENCES States(StateID),
    FOREIGN KEY (CityID) REFERENCES Cities(CityID));

INSERT INTO Universities (UniversityID, UniversityName, UniversityType, StateID, CityID)
VALUES
(1, 'University of Alabama at Birmingham', 'Public', 1, 1),
(2, 'University of Alaska Anchorage', 'Public', 2, 2),
(3, 'Arizona State University', 'Public', 3, 3),
(4, 'University of Arkansas at Little Rock', 'Public', 4, 4),
(5, 'UCLA', 'Public', 5, 5),
(6, 'University of Colorado Denver', 'Public', 6, 6),
(7, 'Trinity College', 'Private', 7, 7),
(8, 'Wilmington University', 'Private', 8, 8),
(9, 'University of Miami', 'Private', 9, 9),
(10, 'Georgia State University', 'Public', 10, 10),
(11, 'University of Hawaii at Manoa', 'Public', 11, 11),
(12, 'Boise State University', 'Public', 12, 12),
(13, 'University of Chicago', 'Private', 13, 13),
(14, 'IUPUI', 'Public', 14, 14),
(15, 'Drake University', 'Private', 15, 15),
(16, 'Wichita State University', 'Public', 16, 16),
(17, 'University of Louisville', 'Public', 17, 17),
(18, 'Tulane University', 'Private', 18, 18),
(19, 'University of Southern Maine', 'Public', 19, 19),
(20, 'Johns Hopkins University', 'Private', 20, 20),
(21, 'Boston University', 'Private', 21, 21),
(22, 'Wayne State University', 'Public', 22, 22),
(23, 'University of Minnesota', 'Public', 23, 23),
(24, 'Jackson State University', 'Public', 24, 24),
(25, 'University of Missouri-Kansas City', 'Public', 25, 25),
(26, 'Montana State University Billings', 'Public', 26, 26),
(27, 'University of Nebraska Omaha', 'Public', 27, 27),
(28, 'UNLV', 'Public', 28, 28),
(29, 'Southern New Hampshire University', 'Private', 29, 29),
(30, 'Rutgers University Newark', 'Public', 30, 30),
(31, 'University of New Mexico', 'Public', 31, 31),
(32, 'New York University', 'Private', 32, 32),
(33, 'UNC Charlotte', 'Public', 33, 33),
(34, 'North Dakota State University', 'Public', 34, 34),
(35, 'Ohio State University', 'Public', 35, 35),
(36, 'Oklahoma City University', 'Private', 36, 36),
(37, 'Portland State University', 'Public', 37, 37),
(38, 'Temple University', 'Public', 38, 38),
(39, 'Brown University', 'Private', 39, 39),
(40, 'College of Charleston', 'Public', 40, 40),
(41, 'Augustana University', 'Private', 41, 41),
(42, 'Vanderbilt University', 'Private', 42, 42),
(43, 'University of Houston', 'Public', 43, 43),
(44, 'University of Utah', 'Public', 44, 44),
(45, 'University of Vermont', 'Public', 45, 45),
(46, 'Regent University', 'Private', 46, 46),
(47, 'University of Washington', 'Public', 47, 47),
(48, 'University of Charleston', 'Private', 48, 48),
(49, 'Marquette University', 'Private', 49, 49),
(50, 'University of Wyoming', 'Public', 50, 50);


CREATE TABLE Airports
    (AirportID INT PRIMARY KEY,
    AirportName VARCHAR(100) NOT NULL,
    AirportCode VARCHAR(5) NOT NULL,
    StateID INT NOT NULL,
    CityID INT NOT NULL,
    FOREIGN KEY (StateID) REFERENCES States(StateID),
    FOREIGN KEY (CityID) REFERENCES Cities(CityID));

INSERT INTO Airports (AirportID, AirportName, AirportCode, StateID, CityID)
VALUES
(1, 'Birmingham-Shuttlesworth International Airport', 'BHM', 1, 1),
(2, 'Ted Stevens Anchorage International Airport', 'ANC', 2, 2),
(3, 'Phoenix Sky Harbor International Airport', 'PHX', 3, 3),
(4, 'Clinton National Airport', 'LIT', 4, 4),
(5, 'Los Angeles International Airport', 'LAX', 5, 5),
(6, 'Denver International Airport', 'DEN', 6, 6),
(7, 'Bradley International Airport', 'BDL', 7, 7),
(8, 'Wilmington Airport', 'ILG', 8, 8),
(9, 'Miami International Airport', 'MIA', 9, 9),
(10, 'Hartsfield-Jackson Atlanta International Airport', 'ATL', 10, 10),
(11, 'Daniel K. Inouye International Airport', 'HNL', 11, 11),
(12, 'Boise Airport', 'BOI', 12, 12),
(13, 'O Hare International Airport', 'ORD', 13, 13),
(14, 'Indianapolis International Airport', 'IND', 14, 14),
(15, 'Des Moines International Airport', 'DSM', 15, 15),
(16, 'Wichita Dwight D. Eisenhower National Airport', 'ICT', 16, 16),
(17, 'Louisville Muhammad Ali International Airport', 'SDF', 17, 17),
(18, 'Louis Armstrong New Orleans International Airport', 'MSY', 18, 18),
(19, 'Portland International Jetport', 'PWM', 19, 19),
(20, 'Baltimore Washington International Airport', 'BWI', 20, 20),
(21, 'Boston Logan International Airport', 'BOS', 21, 21),
(22, 'Detroit Metro Airport', 'DTW', 22, 22),
(23, 'Minneapolis-Saint Paul International Airport', 'MSP', 23, 23),
(24, 'Jackson-Medgar Wiley Evers International Airport', 'JAN', 24, 24),
(25, 'Kansas City International Airport', 'MCI', 25, 25),
(26, 'Billings Logan International Airport', 'BIL', 26, 26),
(27, 'Eppley Airfield', 'OMA', 27, 27),
(28, 'Harry Reid International Airport', 'LAS', 28, 28),
(29, 'Manchester-Boston Regional Airport', 'MHT', 29, 29),
(30, 'Newark Liberty International Airport', 'EWR', 30, 30),
(31, 'Albuquerque International Sunport', 'ABQ', 31, 31),
(32, 'John F. Kennedy International Airport', 'JFK', 32, 32),
(33, 'Charlotte Douglas International Airport', 'CLT', 33, 33),
(34, 'Hector International Airport', 'FAR', 34, 34),
(35, 'John Glenn Columbus International Airport', 'CMH', 35, 35),
(36, 'Will Rogers World Airport', 'OKC', 36, 36),
(37, 'Portland International Airport', 'PDX', 37, 37),
(38, 'Philadelphia International Airport', 'PHL', 38, 38),
(39, 'Rhode Island T. F. Green International Airport', 'PVD', 39, 39),
(40, 'Charleston International Airport', 'CHS', 40, 40),
(41, 'Sioux Falls Regional Airport', 'FSD', 41, 41),
(42, 'Nashville International Airport', 'BNA', 42, 42),
(43, 'George Bush Intercontinental Airport', 'IAH', 43, 43),
(44, 'Salt Lake City International Airport', 'SLC', 44, 44),
(45, 'Burlington International Airport', 'BTV', 45, 45),
(46, 'Norfolk International Airport', 'ORF', 46, 46),
(47, 'Seattle-Tacoma International Airport', 'SEA', 47, 47),
(48, 'Yeager Airport', 'CRW', 48, 48),
(49, 'Milwaukee Mitchell International Airport', 'MKE', 49, 49),
(50, 'Cheyenne Regional Airport', 'CYS', 50, 50);


    -- CREATING VIEW --
CREATE VIEW vw_USAFullInfo
AS
SELECT
    s.StateName,
    s.StateAbbreviation,
    s.Region,
    c.CityName,
    l.LandmarkName,
    u.UniversityName,
    u.UniversityType,
    a.AirportName,
    a.AirportCode
FROM States s
INNER JOIN Cities c ON s.StateID = c.StateID
INNER JOIN Landmarks l ON c.CityID = l.CityID
INNER JOIN Universities u ON c.CityID = u.CityID
INNER JOIN Airports a ON c.CityID = a.CityID;

SELECT * FROM vw_USAFullInfo

DROP VIEW vw_USAFullInfo;

    -- CREATING INDEXES --
CREATE INDEX IX_Cities_StateID ON Cities(StateID);
CREATE INDEX IX_Landmarks_StateID ON Landmarks(StateID);
CREATE INDEX IX_Landmarks_CityID ON Landmarks(CityID);
CREATE INDEX IX_Universities_StateID ON Universities(StateID);
CREATE INDEX IX_Universities_CityID ON Universities(CityID);
CREATE INDEX IX_Airports_StateID ON Airports(StateID);
CREATE INDEX IX_Airports_CityID ON Airports(CityID);

EXEC sp_helpindex 'Cities';
EXEC sp_helpindex 'Landmarks';
EXEC sp_helpindex 'Universities';
EXEC sp_helpindex 'Airports';

DROP INDEX IX_Cities_StateID ON Cities;
DROP INDEX IX_Landmarks_StateID ON Landmarks;
DROP INDEX IX_Landmarks_CityID ON Landmarks;
DROP INDEX IX_Universities_StateID ON Universities;
DROP INDEX IX_Universities_CityID ON Universities;
DROP INDEX IX_Airports_StateID ON Airports;
DROP INDEX IX_Airports_CityID ON Airports;

    -- CREATING SEQUENCE --
CREATE SEQUENCE CityNumberSequence
    AS INT
    START WITH 51
    INCREMENT BY 1
    MINVALUE 51
    NO MAXVALUE
    NO CYCLE
    CACHE 10;

SELECT NEXT VALUE FOR CityNumberSequence;

DROP SEQUENCE CityNumberSequence

    --CREATING FUNCTION --
CREATE FUNCTION fn_CountCitiesByState
    (@StateID INT)
RETURNS INT
AS BEGIN
    DECLARE @CityCount INT;
SELECT @CityCount = COUNT(*)
FROM Cities
WHERE StateID = @StateID;
RETURN @CityCount;
END;

SELECT dbo.fn_CountCitiesByState(5) AS CityCount;

    -- CREATING PROCEDURE --
CREATE PROCEDURE sp_GetCitiesByState
    @StateID INT
AS BEGIN
    SELECT 
        c.CityID,
        c.CityName,
        s.StateName
    FROM Cities c
    INNER JOIN States s ON c.StateID = s.StateID
    WHERE c.StateID = @StateID;
END;
EXEC sp_GetCitiesByState 5;

    -- B4 creating TRIGGER lets create a small log table:
CREATE TABLE CityInsertLog
    (LogID INT IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(50),
    InsertDate DATETIME);

    -- CREATING TRIGGER --
CREATE TRIGGER trg_AfterCityInsert
    ON Cities
AFTER INSERT
AS
BEGIN
    INSERT INTO CityInsertLog (CityName, InsertDate)
    SELECT CityName, GETDATE()
    FROM inserted;
END;

    -- TEST --
INSERT INTO Cities (CityID, CityName, StateID)
VALUES (52, 'Sacramento', 5);

SELECT * FROM CityInsertLog;


    -- COLLATION --
    -- CI = case insensitive
SELECT * FROM States
WHERE StateName = 'texas';

    --AS = accent sensitive
SELECT * FROM States
WHERE StateName = 'Téxas';

SELECT DATABASEPROPERTYEX('USA', 'Collation') AS DatabaseCollation;











