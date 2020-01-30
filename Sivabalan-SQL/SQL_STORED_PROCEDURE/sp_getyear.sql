create procedure sp_getyear
AS
begin
select fiscalYear,Substring(operatingYear,1,4) as year from setup
end


