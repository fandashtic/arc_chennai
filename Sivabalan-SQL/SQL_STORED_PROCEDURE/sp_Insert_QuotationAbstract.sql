Create PROCEDURE sp_Insert_QuotationAbstract(@QuotationName nVarchar(200),         
          @QuotationDate DateTime,        
          @UserName nVarchar(50),        
          @ValidFromDate DateTime,        
          @ValidToDate DateTime,        
          @AllowInvoiceScheme INT,      
          @QuotationType INT,@QuotationSubType int=0,@QuotationLevel int=0,@UOMConv int =0,@SplTax int = 0)        
AS        
DECLARE @DocID INT        
DECLARE @Prefix nVarchar(15)  
Declare @GSTFlag as int

Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'      

Begin Tran          
	UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 33          
	SELECT @DocID = DocumentID - 1 FROM DocumentNumbers WHERE Doctype = 33          
Commit Tran        
SELECT @Prefix = Prefix FROM VoucherPrefix WHERE TranID = 'QUOTATION'        

INSERT INTO QuotationAbstract(DocumentID, QuotationName, QuotationDate, CreationDate,UserName, ValidFromDate,
	ValidToDate,AllowInvoiceScheme, QuotationType, LastModifiedDate, Active, 
	Prefix,QuotationSubType,QuotationLevel,UOMConversion,SpecialTax,GSTFlag)   
VALUES(@DocID, @QuotationName, dbo.StripDateFromTime(@QuotationDate), GetDate(), @UserName, dbo.StripDateFromTime(@ValidFromDate),        
DateAdd(ss,59,DateAdd(mi,59,DateAdd(hh,23,dbo.StripDateFromTime(@ValidToDate)))), @AllowInvoiceScheme, @QuotationType, GetDate(), 1,
@Prefix,@QuotationSubType,@QuotationLevel,@UOMConv,@SplTax,@GSTFlag)        
        
SELECT @@IDENTITY, @DocID 
