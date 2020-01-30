CREATE Procedure [sp_InsertRFAXmlStatus]    
(    
 @RfaID nVarchar(10),@imag image  
)    
AS    
BEGIN    
 DECLARE @ID int    
    
 INSERT INTO tbl_Merp_RFAXmlStatus([RFAID],[BINARYXML],STATUS)    
 SELECT @RfaID,@imag,'0'    
     
 set @ID = @@Identity    
 Select @ID as ID     
END 
