Create Procedure sp_get_RecItemAttributeInfo_ITC
(
@NodeGramps nVarChar(255),
@ChildNode nVarChar(255),
@Attribute nVarChar(255)
)
AS
Select Sno,AllowUpdate from ItemsRecUpdateStatus 
where NodeGramps = @NodeGramps and ChildNode = @ChildNode and Attributes=@Attribute
