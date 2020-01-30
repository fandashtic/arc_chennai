
create proc sp_get_Status (@STK_REQ_NO int)
as
select sum(quantity),sum(pending) from stock_request_detail where stock_req_number = @STK_REQ_NO


