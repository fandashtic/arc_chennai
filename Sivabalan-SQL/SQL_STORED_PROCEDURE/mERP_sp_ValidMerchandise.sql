CREATE Procedure mERP_sp_ValidMerchandise(@Merchandise nVarchar(500))
As
Begin

	Declare @MerchandiseID Int
	Declare @Active Int
	Declare @ErrMsg nVarchar(50)

	

	Select @MerchandiseID =  MerchandiseID , @Active = Active From Merchandise 
	Where Merchandise = @Merchandise 

	

	Set @ErrMsg = ''


	If isNull(@MerchandiseID,0) = 0
		Set @ErrMsg = 'Invalid Merchandise Type'
	Else 
		if @Active = 0 
		Set @ErrMsg = 'Inactive Merchandise Type'


	Select (Case When @ErrMsg = '' Then 1 Else 0  End),@ErrMsg


End
