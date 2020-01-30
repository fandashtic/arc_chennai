CREATE Procedure Get_GRN_ComboID        
As        
Declare @GRNMax int
declare @ComboMax int

Select @ComboMax= IsNull(Max(ComboID),0) + 1 from combo_components
Select @GRNMax= IsNull(Max(ComboID),0) + 1 from grn_combo_components

select @ComboMax,@GRNMax

