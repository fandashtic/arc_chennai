Create procedure sp_get_promisedQty(@ItemCode as nvarchar (15))
as
	select 0
	--SELECT Sum(SODetail.Pending) FROM SOAbstract
	--INNER JOIN SODetail ON SOAbstract.SONumber = SODetail.SONumber
	--WHERE ((([Status] & 128)=0) AND (([Status] & 256)=0)) --and (SODetail.Product_Code)=@ItemCode
	--GROUP BY SODetail.Product_Code
	--HAVING (((SODetail.Product_Code)=@ItemCode));
SET QUOTED_IDENTIFIER OFF
