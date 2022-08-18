-- Final Project Script
-- Ian Tai Ahn
-- 7/31/2022

USE Master

IF EXISTS (SELECT * FROM sysdatabases WHERE name = 'Ahn_LiveMusic')
DROP DATABASE Ahn_LiveMusic

GO

CREATE DATABASE Ahn_LiveMusic

ON PRIMARY
(
NAME = 'Ahn_LiveMusic',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Ahn_LiveMusic.mdf',
--FILENAME LOCAL
SIZE = 4MB,
MAXSIZE = 4MB,
FILEGROWTH = 15%
)

LOG ON

(
NAME = 'Ahn_LiveMusic_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Ahn_LiveMusic.lmdf',
--FILENAME LOCAL
SIZE = 4MB,
MAXSIZE = 4MB,
FILEGROWTH = 15%
)

GO

-- Creating the tables

USE Ahn_LiveMusic

CREATE TABLE MusicGroup
(
MusicGroupID		smallint		NOT NULL	IDENTITY(1,1) PRIMARY KEY,
GroupName			varchar(20)		NOT NULL,
MemberCount			tinyint			NULL,
MusicDescription	varchar(150)		NOT NULL
)

CREATE TABLE MusicGroupShow
(
MusicGroupShowID	smallint	NOT NULL	IDENTITY(1,1) PRIMARY KEY,
MusicGroupID		smallint	NOT NULL,
ShowID				smallint	NOT NULL
)

CREATE TABLE Show
(
ShowID					smallint		NOT NULL	IDENTITY(1,1) PRIMARY KEY,
ShowName				varchar(50)		NOT NULL,
ShowStart				smalldatetime	NOT NULL,
ShowEnd					smalldatetime	NOT NULL,
TwentyOneUp				bit				NOT NULL,
VenueDescription		varchar(200)		NULL,
MusicGroupShowID		smallint		NOT NULL
)

CREATE TABLE HotelShow
(
HotelShowID		smallint	NOT NULL	IDENTITY(1,1) PRIMARY KEY,
ShowID			smallint	NOT NULL,
HotelID			smallint	NOT NULL
)

-- May Omit TicketPurchaseDate..
CREATE TABLE Ticket
(
TicketID			smallint		NOT NULL	IDENTITY(1,1) PRIMARY KEY,
TicketPrice			smallmoney		NOT NULL,
TicketQty			tinyint			NOT NULL,
--TicketPurchaseDate	smalldatetime	NOT NULL,
ShowID				smallint		NOT NULL
)

CREATE TABLE CustomerTicket
(
CustomerTicketID	smallint	NOT NULL	IDENTITY(1,1) PRIMARY KEY,
TicketID			smallint	NOT NULL,
CustID				smallint	NOT NULL
)

CREATE TABLE Customer
(
CustID					smallint		NOT NULL	IDENTITY(1,1) PRIMARY KEY,
CustFirst				varchar(30)		NOT NULL,
CustLast				varchar(30)		NOT NULL,
CustEmail				varchar(30)		NOT NULL,
CustDOB					varchar(20)		NOT NULL,
CustPhone				varchar(20)		NOT NULL,
CustHotelGuestStatus	bit				NOT NULL
)

CREATE TABLE CreditCard
(
CreditCardID	smallint		NOT NULL	IDENTITY(1,1) PRIMARY KEY,
CCType			varchar(5)		NOT NULL,
CCNumber		varchar(16)		NOT NULL,
CCCardHolder	varchar(40)		NOT NULL,
CCExpiration	smalldatetime	NOT NULL,
CustID			smallint		NOT NULL
)

CREATE TABLE Payment
(
PaymentID			smallint		NOT NULL	IDENTITY(1,1) PRIMARY KEY,
PaymentDate			smalldatetime	NOT NULL,
PaymentAmount		smallmoney		NOT NULL,
PaymentComments		varchar(150)		NULL
--CustomerPaymentID	smallint		NOT NULL
)

CREATE TABLE CustomerPayment
(
CustomerPaymentID	smallint	NOT NULL	IDENTITY(1,1) PRIMARY KEY,
CustID				smallint	NOT NULL,
PaymentID			smallint	NOT NULL
)

-- creates hotel table from Ahn_Farms using linked server 
SELECT * INTO Hotel FROM localserver.Ahn_FARMS.dbo.Hotel
--SELECT * FROM Hotel

-- Referencing the Foreign Keys
GO

ALTER TABLE MusicGroupShow
	ADD CONSTRAINT FK_MusicGroupID
	FOREIGN KEY (MusicGroupID) REFERENCES MusicGroup (MusicGroupID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT FK_ShowMGSID
	FOREIGN KEY (ShowID) REFERENCES Show (ShowID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	
ALTER TABLE Show
	ADD CONSTRAINT FK_MusicGroupShowID
	FOREIGN KEY (MusicGroupShowID) REFERENCES MusicGroupShow (MusicGroupShowID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION


ALTER TABLE Hotel
ADD CONSTRAINT PK_HotelID PRIMARY KEY (HotelID);

ALTER TABLE HotelShow
	ADD CONSTRAINT FK_ShowID
	FOREIGN KEY (ShowID) REFERENCES Show (ShowID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_HotelID
	FOREIGN KEY (HotelID) REFERENCES Hotel (HotelID)
	ON UPDATE CASCADE
	ON DELETE CASCADE

ALTER TABLE Ticket
	ADD CONSTRAINT FK_ShowTID
	FOREIGN KEY (ShowID) REFERENCES Show (ShowID)
	ON UPDATE CASCADE
	ON DELETE CASCADE

ALTER TABLE CustomerTicket
	ADD CONSTRAINT FK_TicketID
	FOREIGN KEY (TicketID) REFERENCES Ticket (TicketID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_CustCTID
	FOREIGN KEY (CustID) REFERENCES Customer (CustID)
	ON UPDATE CASCADE
	ON DELETE CASCADE

	-- testing with no FK
	-- Def better without a foreign key.
--ALTER TABLE Payment
--	ADD CONSTRAINT FK_CustomerPaymentPID
--	FOREIGN KEY (CustomerPaymentID) REFERENCES CustomerPayment (CustomerPaymentID)
--	ON UPDATE NO ACTION
--	ON DELETE NO ACTION

ALTER TABLE CreditCard
	ADD CONSTRAINT FK_CustCCID
	FOREIGN KEY (CustID) REFERENCES Customer (CustID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	
ALTER TABLE CustomerPayment
	ADD CONSTRAINT FK_CustCPID
	FOREIGN KEY (CustID) REFERENCES Customer (CustID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION,

	CONSTRAINT FK_PaymentCPID
	FOREIGN KEY (PaymentID) REFERENCES Payment (PaymentID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
GO

BULK INSERT CreditCard FROM 'C:\LiveMusicDB\CreditCard.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM CreditCard

BULK INSERT Customer FROM 'C:\LiveMusicDB\Customer.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM Customer

BULK INSERT CustomerTicket FROM 'C:\LiveMusicDB\CustomerTicket.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM CustomerTicket

BULK INSERT HotelShow FROM 'C:\LiveMusicDB\HotelShow.txt' 
WITH (FIELDTERMINATOR='|')
--SELECT * FROM HotelShow

BULK INSERT MusicGroup FROM 'C:\LiveMusicDB\MusicGroup.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM MusicGroup

BULK INSERT MusicGroupShow FROM 'C:\LiveMusicDB\MusicGroupShow.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM MusicGroupShow

BULK INSERT Payment FROM 'C:\LiveMusicDB\Payment.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM Payment

BULK INSERT Show FROM 'C:\LiveMusicDB\Show.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM Show

BULK INSERT Ticket FROM 'C:\LiveMusicDB\Ticket.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM Ticket

BULK INSERT CustomerPayment FROM 'C:\LiveMusicDB\CustomerPayment.txt' 
WITH (FIELDTERMINATOR='|' )
--SELECT * FROM CustomerPayment

-- Start of queries that do stuff!

-- Start of Trigger 1 tr_CheckCustAge *DONE

--EXEC sp_addmessage 60008, 10, 'Error. Sorry, %s is younger than 21. Cannot purchase ticket to this concert.'
--SELECT * FROM sys.messages WHERE message_id = 60006;

GO
CREATE TRIGGER tr_CheckCustAge ON CustomerTicket
AFTER INSERT
AS
DECLARE @CustDOB	smalldatetime
DECLARE @CustID		smallint
DECLARE @CustFirst  varchar(20)
DECLARE @TicketID	smallint
DECLARE @ShowID		smallint
DECLARE @TwentyOneUp bit
DECLARE @LessThanTwentyOne smalldatetime

BEGIN
	SELECT @CustID = (SELECT CustID FROM INSERTED)
	SELECT @TicketID = (SELECT TicketID FROM INSERTED)
	SELECT @ShowID = (SELECT ShowID FROM Ticket WHERE TicketID = @TicketID)
	SELECT @CustFirst = (SELECT CustFirst FROM Customer WHERE CustID = @CustID)
	SELECT @CustDOB = (SELECT CustDOB FROM Customer WHERE CustID = @CustID)
	SELECT @TwentyOneUp = (SELECT TwentyOneUp FROM Show WHERE ShowID = @ShowID)
	
	SELECT @LessThanTwentyOne = DATEADD(YEAR, -21, GETDATE())
	--PRINT @LessThanTwentyOne
	--PRINT @CustDOB
	--PRINT @TwentyOneUp
	--PRINT @ShowID
	--PRINT @CustID

	IF (@TwentyOneUp = 1 AND @CustDOB > @LessThanTwentyOne)
		BEGIN
			RAISERROR(60008, 10, 1, @CustFirst)
			ROLLBACK
		END
END
GO
-- UNCOMMENT BEFORE SUBMISSION
/*
INSERT INTO CustomerTicket(TicketID, CustID) -- expecting error here, 
VALUES (13,6)
GO
INSERT INTO CustomerTicket(TicketID, CustID) -- expecting success here, 
VALUES (13,5)
GO
SELECT * FROM CustomerTicket
*/

-- Trigger 2 *DONE
GO
CREATE TRIGGER tr_AddCustomerPayment ON CustomerTicket
AFTER INSERT
AS
DECLARE @CustID		 smallint
DECLARE @TicketID	 smallint
DECLARE @TicketPrice smallmoney
DECLARE @TicketQty	 tinyint
DECLARE @PaymentAmount  smallmoney
DECLARE @PaymentID		   smallint
BEGIN
	SELECT @CustID = (SELECT CustID FROM INSERTED)
	SELECT @TicketID = (SELECT TicketID FROM INSERTED)
	SELECT @TicketPrice = (SELECT TicketPrice FROM Ticket WHERE TicketID = @TicketID)
	SELECT @TicketQty = (SELECT TicketQty FROM Ticket WHERE TicketID = @TicketID)
	SELECT @PaymentAmount = @TicketPrice * @TicketQty

	INSERT INTO Payment (PaymentDate, PaymentAmount, PaymentComments)
	VALUES (GETDATE(), @PaymentAmount, 'Autoinserted via trigger when inserting into CustomerTicket')
	PRINT 'added into payment'

	SELECT @PaymentID = @@IDENTITY
	INSERT INTO CustomerPayment(CustID, PaymentID)
	VALUES (@CustID,@PaymentID)
	PRINT 'added into CustomerPayment'
	--testing
	--PRINT @@IDENTITY
	--PRINT @PaymentID
	--PRINT @TicketPrice
	--PRINT @TicketQty
	--PRINT @PaymentAmount
END
GO
--UNCOMMENT WHEN SUBMITTING -- test this one further, i dont think i need all of these select statements.
/*
SELECT * FROM CustomerTicket
SELECT * FROM Payment
SELECT * FROM CustomerPayment
INSERT INTO CustomerTicket(TicketID, CustID)
VALUES (8,2)
GO
SELECT * FROM CustomerTicket
SELECT * FROM Payment
SELECT * FROM CustomerPayment
*/

-- sproc 4
-- procedure that does the same thing pretty much. THIS IS NEEDED FOR THE TRIGGER : CheckCustomerGuestStatus 
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_AddDiscountOnPayment')
	DROP PROCEDURE sp_AddDiscountOnPayment
GO
CREATE PROCEDURE sp_AddDiscountOnPayment
@PaymentIDP smallint
AS
BEGIN
DECLARE @DiscountPercent decimal(4,2)
DECLARE @DiscountAmount smallmoney
DECLARE @PaymentAmount  smallmoney
DECLARE @CustID smallint
DECLARE @CustHotelGuestStatus bit

	SELECT @CustID = (SELECT TOP 1 CustID FROM CustomerPayment WHERE PaymentID = @PaymentIDP)
	SELECT @CustHotelGuestStatus = (SELECT CustHotelGuestStatus FROM Customer WHERE CustID = @CustID)

	IF (@CustHotelGuestStatus = 1)
	BEGIN
		DECLARE @TotalPaymentAmountBefore smallmoney
		SELECT @DiscountPercent = (SELECT * FROM OPENROWSET('MSDASQL', 'DRIVER={SQL Server};SERVER=IANTAI\SQLEXPRESS;UID=sa;PWD=pass123', 'Select DiscountPercent From Ahn_FARMS.dbo.Discount WHERE DiscountID = 24'))
		SELECT @TotalPaymentAmountBefore = (SELECT PaymentAmount FROM Payment WHERE PaymentID = @PaymentIDP)

		SET @DiscountAmount = (@TotalPaymentAmountBefore) * @DiscountPercent
		SET @PaymentAmount = (@TotalPaymentAmountBefore) - @DiscountAmount

		UPDATE Payment
		SET PaymentAmount = @PaymentAmount
		WHERE PaymentID = @PaymentIDP
	END
		-- For testing
		PRINT @DiscountPercent
		PRINT @DiscountAmount
		PRINT @PaymentAmount
		PRINT 'End of adding discounts proc'
END
GO

-- UNCOMMENT FOR SUBMISSION
/*
SELECT * FROM Payment
EXEC sp_AddDiscountOnPayment
@PaymentIDP = 1
SELECT * FROM Payment
GO
*/

-- sproc 6
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_AddDiscountsUponGuestSwitch')
	DROP PROCEDURE sp_AddDiscountsUponGuestSwitch
GO
CREATE PROCEDURE sp_AddDiscountsUponGuestSwitch
@CustIDP smallint
AS
BEGIN
		DECLARE @PaymentIDC		 smallint --outer
		DECLARE @PaymentDate	 smalldatetime
		DECLARE @PaymentAmount	 smallmoney
		DECLARE @PaymentComments varchar(30)

		DECLARE OuterLoop_Cursor CURSOR
			FOR 
			SELECT PaymentID FROM CustomerPayment WHERE CustID = @CustIDP
		OPEN OuterLoop_Cursor
		FETCH NEXT FROM OuterLoop_Cursor INTO @PaymentIDC
		WHILE @@FETCH_STATUS = 0
			BEGIN
			PRINT 'outer loop start'
			EXEC sp_AddDiscountOnPayment
			@PaymentIDP = @PaymentIDC
			DECLARE UpdatePayment_Cursor CURSOR
			FOR 
				SElECT PaymentDate, PaymentAmount, PaymentComments 
				FROM Payment
				WHERE PaymentID = @PaymentIDC
			OPEN UpdatePayment_Cursor
			FETCH NEXT FROM UpdatePayment_Cursor INTO @PaymentDate, @PaymentAmount, @PaymentComments
			WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT 'start of updating'
					UPDATE Payment
					SET PaymentDate = @PaymentDate, PaymentAmount = @PaymentAmount, PaymentComments = @PaymentComments
					WHERE PaymentID = @PaymentIDC
					PRINT 'End of updating'
					FETCH NEXT FROM UpdatePayment_Cursor INTO  @PaymentDate, @PaymentAmount, @PaymentComments
				END
			CLOSE UpdatePayment_Cursor
			DEALLOCATE UpdatePayment_Cursor
			PRINT 'end of inner loop'
			FETCH NEXT FROM OuterLoop_Cursor INTO @PaymentIDC
			END
			PRINT 'End of outerloop'
		CLOSE OuterLoop_Cursor
		DEALLOCATE OuterLoop_Cursor
	PRINT 'End of nested cursors'
END
GO

-- 2 isnt a hotel guest, but 1 is.
/*
SELECT * FROM Payment
EXEC sp_AddDiscountsUponGuestSwitch
@CustIDP = 2
SELECT * FROM Payment
*/

-- trigger 4
GO
CREATE TRIGGER tr_CheckCustomerGuestStatus ON Customer
AFTER UPDATE
AS
DECLARE @CustID					smallint
DECLARE @CustHotelGuestStatus	bit

SELECT @CustID = (SELECT CustID FROM INSERTED)
SELECT @CustHotelGuestStatus = (SELECT CustHotelGuestStatus FROM INSERTED)
BEGIN
IF (UPDATE(CustHotelGuestStatus))
	BEGIN
	IF (@CustHotelGuestStatus = 1)
		BEGIN
		EXEC sp_AddDiscountsUponGuestSwitch
		@CustIDP = @CustID
		END
	END
END
GO

 --UNCOMMENT FOR SUBMISSION!
 -- This is the coolest sql statement I've written i think.
 /*
 SELECT * FROM Payment
UPDATE Customer
SET CustHotelGuestStatus = 1
WHERE CustID = 2
SELECT * FROM Payment
*/

--Trigger 3 Updates Customer Payment
GO
CREATE TRIGGER tr_AddDiscountOnPayment ON CustomerPayment
AFTER INSERT
AS
DECLARE @PaymentID	smallint
SELECT @PaymentID = (SELECT PaymentID FROM INSERTED)
BEGIN
		BEGIN
		EXEC sp_AddDiscountOnPayment
		@PaymentIDP = @PaymentID
		END
END
GO

-- This demos the big mamma jamma script you got going.
-- fires trigger one first, and then fires trigger 3, afterwards, and the procedureadddiscountonpayment
/*
SELECT * FROM CustomerTicket
SELECT * FROM Payment
SELECT * FROM CustomerPayment
INSERT INTO CustomerTicket(TicketID, CustID)
VALUES (8,2) -- wont add the discount since I'm not a guest, if we change to VALUES (8,1) we get the update.
GO
SELECT * FROM CustomerTicket
SELECT * FROM Payment
SELECT * FROM CustomerPayment
*/

/*
SELECT * FROM CustomerTicket
GO
INSERT INTO CustomerTicket(TicketID, CustID)
VALUES (12,1)
GO
SELECT * FROM CustomerTicket
SELECT * FROM Payment
*/

-- Sproc 1 showheadcount
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_ShowHeadCount')
	DROP PROCEDURE sp_ShowHeadCount
GO
CREATE PROCEDURE sp_ShowHeadCount
@ShowID		smallint,
@TicketQtyTotal smallint OUTPUT
AS
BEGIN
	DECLARE @TicketQty		smallint
	SET @TicketQtyTotal = 0

	DECLARE HeadCount_Cursor CURSOR
		FOR 
			SElECT TicketQty
			FROM Ticket
			LEFT JOIN Show
			ON Ticket.ShowID = Show.ShowID
			WHERE @ShowID = Ticket.ShowID
		OPEN HeadCount_Cursor
		FETCH NEXT FROM HeadCount_Cursor INTO @TicketQty
		WHILE @@FETCH_STATUS = 0
			BEGIN
				--PRINT 'TicketQty ' + CAST(@TicketQty AS varchar(15))
				SET @TicketQtyTotal += @TicketQty
				--PRINT 'TicketQtyTotal ' + CAST(@TicketQtyTotal AS varchar(15))
				FETCH NEXT FROM HeadCount_Cursor INTO  @TicketQty
			END
		CLOSE HeadCount_Cursor
		DEALLOCATE HeadCount_Cursor
		RETURN
END
GO

-- UNCOMMENT FOR SUBMISSION
/*
DECLARE @TicketQtyTotalR smallint
EXEC sp_ShowHeadCount
@ShowID = 2,
@TicketQtyTotal = @TicketQtyTotalR OUTPUT
PRINT  'HeadCount: ' + CAST(@TicketQtyTotalR AS varchar(20))
SELECT * FROM Ticket
*/
-- Start of Sproc 2 Calculate Show Earnings

GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_CalculateShowEarnings')
	DROP PROCEDURE sp_CalculateShowEarnings
GO
CREATE PROCEDURE sp_CalculateShowEarnings
@ShowIDP		smallint,
@ShowEarnings smallint OUTPUT
AS
BEGIN
	DECLARE @TicketQty	smallint
	DECLARE @TicketPrice smallmoney

	EXEC sp_ShowHeadCount
	@ShowID = @ShowIDP,
	@TicketQtyTotal = @TicketQty OUTPUT

	SELECT @TicketPrice = (SELECT TOP 1 TicketPrice FROM Ticket WHERE Ticket.ShowID = @ShowIDP)
	SET @ShowEarnings = @TicketQty * @TicketPrice
	RETURN
END
GO

-- UNCOMMENT FOR SUBMISSION
/*
DECLARE @ShowEarningsR smallmoney
EXEC sp_CalculateShowEarnings
@ShowIDP = 3,
@ShowEarnings = @ShowEarningsR OUTPUT
PRINT 'Show Earnings: ' + CAST(@ShowEarningsR AS varchar(20))
SELECT * FROM Show
SELECT * FROM Ticket
*/
-- Sproc 3 begin! sp_AddCustomer. should be ezy..... 

GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_AddCustomer')
	DROP PROCEDURE sp_AddCustomer
GO
CREATE PROCEDURE sp_AddCustomer
	@CustFirst				 varchar(30),
	@CustLast				 varchar(30),
	@CustEmail				 varchar(30),
	@CustDOB				 varchar(30),
	@CustPhone				 varchar(30),
	@CustHotelGuestStatus	 bit
AS
	BEGIN
		INSERT INTO Customer(CustFirst, CustLast, CustEmail, CustDOB, CustPhone, CustHotelGuestStatus)
		VALUES (@CustFirst, @CustLast, @CustEmail, @CustDOB, @CustPhone, @CustHotelGuestStatus)
	END
GO

-- UNCOMMENT FOR SUBMISSION
/*
EXEC sp_AddCustomer
	@CustFirst = 'Harry',
	@CustLast  = 'Plopper',
	@CustEmail = 'Hogwarts80@gmail.com',
	@CustDOB = '7/07/1977',
	@CustPhone = '801-818-4811',
	@CustHotelGuestStatus = 0
	SELECT * FROM Customer
	*/

-- Start of Sproc 5 sp_HotelGuestDiscount  
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_HotelGuestDiscount')
	DROP PROCEDURE sp_HotelGuestDiscount
GO
CREATE PROCEDURE sp_HotelGuestDiscount
AS
BEGIN
	INSERT INTO localserver.Ahn_FARMS.dbo.Discount (DiscountDescription, DiscountExpiration, DiscountRules, DiscountPercent, DiscountAmount)
	VALUES ('Hotel guest ticket discount', '01/01/2022', 'Has to be a guest at the Hotel.', .2, NULL)
END
GO

-- DONT run HotelGuestDiscount again or else duplicates will form in remote database.
--EXEC sp_HotelGuestDiscount -- execute only once! I know, kind of dumb. haha.
--DELETE FROM localserver.Ahn_FARMS.dbo.Discount WHERE DiscountID = 18
--SELECT * FROM localserver.Ahn_FARMS.dbo.Discount

-- Start of User Defined Functions!

-- UDF 1 dbo.ShowDatesAndLocations

GO
IF OBJECT_ID (N'dbo.ShowDatesAndLocations') IS NOT NULL
DROP FUNCTION dbo.ShowDatesAndLocations
GO
CREATE FUNCTION dbo.ShowDatesAndLocations
(@MusicGroupID	smallint
)
RETURNS @ShowDatesAndLocations TABLE
(ShowName		varchar(50),
 ShowStart		smalldatetime,
 ShowEnd		smalldatetime,
 HotelName		varchar(30),
 HotelAddress	varchar(30)
 )
AS
	BEGIN
	WITH DateTimeLocationTable(ShowNameX, ShowStartX, ShowEndX, HotelNameX, HotelAddressX)
	AS
	(SElECT ShowName, ShowStart, ShowEnd, HotelName, HotelAddress
	FROM Show
	LEFT JOIN MusicGroupShow
	ON MusicGroupShow.ShowID = Show.ShowID
	LEFT JOIN HotelShow
	ON HotelShow.ShowID = Show.ShowID
	LEFT JOIN Hotel
	ON Hotel.HotelID = HotelShow.HotelID
	WHERE MusicGroupID = @MusicGroupID)

	INSERT @ShowDatesAndLocations
	SELECT ShowNameX, ShowStartX, ShowEndX, HotelNameX, HotelAddressX
	FROM DateTimeLocationTable
	RETURN
	END
GO
-- UNCOMMENT FOR SUBMISSION.. GOOD JOB!
/*
SELECT * FROM MusicGroup
SELECT * FROM dbo.ShowDatesAndLocations(5)
*/

-- udf 2
IF OBJECT_ID (N'dbo.ShowDateRange') IS NOT NULL
DROP FUNCTION dbo.ShowDateRange
GO
CREATE FUNCTION dbo.ShowDateRange
(@Date		smalldatetime
)
RETURNS @ShowsWithinRange TABLE
(ShowName		varchar(50),
 ShowStart		smalldatetime,
 ShowEnd		smalldatetime,
 HotelName		varchar(30),
 HotelAddress	varchar(30)
 )
AS
	BEGIN
	DECLARE @ShowError varchar(50)
	DECLARE @ShowNull smalldatetime
	SET @ShowError = 'The chosen date isnt within any current show dates.'
	SELECT @ShowNull = (SELECT TOP 1 ShowStart FROM Show WHERE @Date BETWEEN ShowStart AND ShowEnd);
	IF (@ShowNull IS NULL)
		BEGIN
		INSERT @ShowsWithinRange
		SELECT @ShowError, NULL, NULL, NULL, NULL
		END;

	WITH DateTimeLocationTable(ShowNameX, ShowStartX, ShowEndX, HotelNameX, HotelAddressX)
	AS
	(SElECT ShowName, ShowStart, ShowEnd, HotelName, HotelAddress
	FROM Show
	LEFT JOIN MusicGroupShow
	ON MusicGroupShow.ShowID = Show.ShowID
	LEFT JOIN HotelShow
	ON HotelShow.ShowID = Show.ShowID
	LEFT JOIN Hotel
	ON Hotel.HotelID = HotelShow.HotelID
	WHERE @Date BETWEEN ShowStart AND ShowEnd)
	
	INSERT @ShowsWithinRange
	SELECT ShowNameX, ShowStartX, ShowEndX, HotelNameX, HotelAddressX
	FROM DateTimeLocationTable
	RETURN
	END
GO
--UNCOMMENT BEFORE SUBMISSION!

--SELECT * FROM Show
--SELECT * FROM dbo.ShowDateRange('10/03/2022') -- gives back shows
--SELECT * FROM dbo.ShowDateRange('10/03/2023') -- prdocues error

USE Master
DROP DATABASE Ahn_LiveMusic
