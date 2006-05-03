<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<formtemplate id="rate_project">
<table border="0">
<tr>
   <td>
       &nbsp;
   </td>
   <multiple name="dimensions">
       <th align="center">
           @dimensions.title@
       </th>
       <td>
           &nbsp;&nbsp;&nbsp;&nbsp;
       </td>
   </multiple>
</tr>	
   <multiple name="assignees">
       <tr>
           <if @assignees.rownum@ eq 1>
               <td class="form-label">
                   <br>@assignees.label@ <span class="form-required-mark">*</span>
               </td>	
           </if>
           <else>
               <td class="form-label">
                   @assignees.label@ <span class="form-required-mark">*</span>
               </td>	
           </else>
           <multiple name="dimensions">
               <td>
	           <table border="0">
	           <tr>
                      <formgroup id="@assignees.party_id@.@dimensions.dimension_key@">
	                  <th align="center">
                             <if @assignees.rownum@ eq 1>
                                 @formgroup.label;noquote@<br>
                             </if>
                             @formgroup.widget;noquote@
                          </th>
	              </formgroup>
	           </tr>
	           </table>
               </td>
               <td>
                   &nbsp;
               </td>	
           </multiple>
       </tr>
   </multiple>
<tr>
    <td>
        &nbsp;
    </td>
    <td>
        <input type=submit value="#project-manager.rate#">
    </td>
</tr>
</table>
</formtemplate>


