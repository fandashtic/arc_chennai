CREATE procedure sp_Insert_ServiceTypeMaster
(
@serviceaccountcode nvarchar(50),
@servicename nvarchar(50),
@taxname nvarchar(150),
@active nvarchar(50),
@mode nvarchar(50)
)
AS
BEGIN

Declare @Taxid int

select @Taxid =Tax_Code from tax where  Tax_Description= @taxname

-- active code
IF @active = 'Yes'
Set @active = 1
ELSE
Set @active = 0

--mode code

IF @mode = 'New'
BEGIN

IF NOT EXISTS (SELECT DISTINCT servicename FROM ServiceTypeMaster WHERE servicename = @servicename)
BEGIN

Insert into ServiceTypeMaster(serviceaccountcode,servicename,MapTaxId,active,dateofcreation)
Values (@serviceaccountcode,@servicename,@taxid,@active,getdate())
END
ELSE BEGIN
select 'Service Name Already Exist'
END
END
ELSE
BEGIN
UPDATE ServiceTypeMaster SET serviceaccountcode = @serviceaccountcode, MapTaxId=@taxid,active= @active WHERE servicename = @servicename

END
END
