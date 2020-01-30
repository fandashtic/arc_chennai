
CREATE PROCEDURE sp_Save_Setup
                 (@COMPANYID NVARCHAR (50),
                  @COMPANYNAME NVARCHAR (255),   
                  @BILLINGADDRESS NVARCHAR (255),
                  @SHIPPINGADDRESS NVARCHAR (255),
                  @TELEPHONE NVARCHAR (50),
                  @FISCALYEAR INT,
                  @VOUCHERSTART INT,
		  @STREGN nvarchar(50),
		  @STLABEL nvarchar(50),
		  @CTREGN nvarchar(50),
		  @CTLABEL nvarchar(50),
		  @DL20 nvarchar(50),
		  @DL21 nvarchar(50))
AS
IF EXISTS (SELECT TOP 1 RegisteredOwner FROM Setup WHERE RegisteredOwner = @CompanyID)
	BEGIN
	EXEC sp_update_setup @COMPANYID,
                  @COMPANYNAME,   
                  @BILLINGADDRESS,
                  @SHIPPINGADDRESS,
                  @TELEPHONE,
                  @FISCALYEAR,
                  @VOUCHERSTART,
		  @STREGN,
		  @STLABEL,
		  @CTREGN,
		  @CTLABEL,
		  @DL20,
		  @DL21
	END
ELSE
	BEGIN
	EXEC sp_insert_Setup @COMPANYID,
                  @COMPANYNAME,   
                  @BILLINGADDRESS,
                  @SHIPPINGADDRESS,
                  @TELEPHONE,
                  @FISCALYEAR,
                  @VOUCHERSTART,
		  @STREGN,
		  @STLABEL,
		  @CTREGN,
		  @CTLABEL,
		  @DL20,
		  @DL21
	END



