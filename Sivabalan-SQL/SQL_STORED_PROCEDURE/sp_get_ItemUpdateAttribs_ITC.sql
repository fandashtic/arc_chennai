Create Procedure sp_get_ItemUpdateAttribs_ITC
As
Select Sno,Upper(Attributes) from ItemsRecUpdateStatus 
where NodeGramps = 'Items'
Order by Sno
