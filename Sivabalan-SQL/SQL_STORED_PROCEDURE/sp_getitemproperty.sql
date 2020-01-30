CREATE procedure sp_getitemproperty (@itemcode nvarchar(30))
as
select track_batches, price_option, track_inventory, virtual_track_batches, TrackPKD, 
Isnull(Vat, 0) 'Vat', Isnull(CollectTaxSuffered, 0) 'CollectTaxSuffered'
from items, itemcategories 
where product_code = @itemcode and itemcategories.categoryid = items.categoryid

