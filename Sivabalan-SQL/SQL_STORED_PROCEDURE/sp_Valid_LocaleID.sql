Create procedure sp_Valid_LocaleID as
If exists(select LocaleId from setup where isnull(localeid,0) not in(3081,10249,4105,
9225,6153,8201,5129,13321,7177,11273,2057,1033,12297)) 
	select 1
else
	select 0

--Zimbabwe=12297
--United states=1033
--United Kingdom=2057
--Trindad=11273
--South africa=7177
--Philipines=13321
--New Zealand=5129
--Jamaica=8201
--Ireland=6153
--carribian=9225
--cannada=4105
--Belize=10249
--Australia=3081

