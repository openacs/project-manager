   <multiple name=pm_packages>    

    <if @filter_p@ ne 0>
        <form method=post name=search action=index>
          #project-manager.Search#<br />
          <input type=text name=searchterm value="@searchterm@" size="15" />
          @hidden_vars;noquote@
          <input type="submit" value="Go" />
        </form>
        
        @category_select;noquote@

      </if>
        <listtemplate name="@pm_packages.list_id@"></listtemplate>
        
   </multiple>




