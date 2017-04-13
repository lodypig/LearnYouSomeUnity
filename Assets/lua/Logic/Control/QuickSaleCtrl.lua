
function CreateQuickSaleCtrl()
	local QuickSale = {};
	QuickSale.StateList = {};
	QuickSale.SelectedList = {};
	function QuickSale.writeSaleState()
		for i = 1, #QuickSale.SelectedList do
			if QuickSale.SelectedList[i] then
				QuickSale.StateList[i] = 1;
			else
				QuickSale.StateList[i] = 0;
			end
		end
		
		local msg = {cmd = "write_sale_state", state = QuickSale.StateList};
	    Send(msg);
	end

	function QuickSale.getSaleState(cb)
		local msg = {cmd = "get_sale_state"}
		Send(msg, cb);
	end
  	return QuickSale;
end

client.quickSaleCtrl = CreateQuickSaleCtrl();