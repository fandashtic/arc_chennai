CREATE procedure sp_ser_updatetax(
@Description nvarchar(255),
@Percentage decimal(18,6),
@LastModifiedDate datetime,
@Active int)
AS
update servicetaxmaster set active = @active,
Percentage = @Percentage,
LastModificationdate = @LastModifiedDate
where [Description] = @Description



