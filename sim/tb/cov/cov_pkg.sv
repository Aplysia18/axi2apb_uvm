covergroup covport_ab with function sample (int bb, int cc, bit enable);
	option.per_instance = 1;
    len_p:coverpoint bb
          { bins lo[]={[0:49]};
            bins hi={[50:$]};
		  }

     high_p:coverpoint cc
          {bins lo[]={[0:49]};
           bins hi[4]={[50:200]};
		  }

     cross len_p,high_p iff(enable==1);      
endgroup

