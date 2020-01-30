Create Function sp_ser_getitemcolor(@ServiceInvId int,@ItemSpec1 nvarchar(50),
@ProductCode nvarchar(15))
Returns nvarchar(50)as
Begin
Declare @Color nvarchar(50)
select @Color = GM.[Description] from
ServiceInvoiceDetail SerDet
Left Outer Join ItemInformation_Transactions IIT on IIT.Documentid = SerDet.Serialno and IsNull(IIT.DocumentType,0) = 3
Left Outer Join Generalmaster GM on IIT.color = GM.Code
where SerDet.ServiceInvoiceID = @ServiceInvId and Product_Code = @ProductCode
and SerDet.Product_Specification1 = @ItemSpec1 and IsNull(SerDet.Type,0) = 0
Return IsNull(@Color,'')
End


