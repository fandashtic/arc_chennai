Create VIEW  [dbo].[V_DSPM_TLC_NOA]
([SalesmanID],	
[Group_ID],
[PMProductID],
[PMProductName],
[Parameter],	
[Target],
[Achievement],		
[ValidFromDate],
[ValidToDate]) 
AS

Select [SalesmanID],[Group_ID],[PMProductID],[PMProductName],[Parameter],[Target],[Achievement],[ValidFromDate],[ValidToDate]
From dbo.FN_GetDSPMView_TLCNOA()

