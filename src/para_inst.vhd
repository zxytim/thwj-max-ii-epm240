para_inst : para PORT MAP (
		addr	 => addr_sig,
		nread	 => nread_sig,
		data_valid	 => data_valid_sig,
		dataout	 => dataout_sig,
		nbusy	 => nbusy_sig,
		osc	 => osc_sig
	);
