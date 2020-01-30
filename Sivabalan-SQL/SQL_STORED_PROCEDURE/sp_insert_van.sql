CREATE PROC sp_insert_van  
 (@VAN NVARCHAR(50),  
  @VANNO NVARCHAR(50))  
AS  
INSERT INTO VAN (Van,Van_Number,Active) VALUES(@VAN, @VANNO, 1) 

