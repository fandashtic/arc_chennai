
CREATE Procedure sp_insert_Disclaimer
                (@TRANID NVARCHAR (50),
                 @DISCLAIMERTEXT NVARCHAR (4000))
AS
Insert into Disclaimer
            (TranID,
             DisclaimerText)
Values 
      (@TRANID,
       @DISCLAIMERTEXT)



