<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title><#709#> - <#306#></title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="pwdmeter.css">
<link rel="stylesheet" type="text/css" href="device-map/device-map.css">
<link rel="stylesheet" type="text/css" href="css/icon.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/js/httpApi.js"></script>
<style>
.cancel{
border: 2px solid #898989;
border-radius:50%;
background-color: #898989;
}
.check{
border: 2px solid #093;
border-radius:50%;
background-color: #093;
}
.cancel, .check{
width: 22px;
height: 22px;
margin:0 auto;
transition: .35s;
}
.cancel:active, .check:active{
transform: scale(1.5,1.5);
opacity: 0.5;
transition: 0;
}
.all_enable{
border: 1px solid #393;
color: #393;
}
.all_disable{
border: 1px solid #999;
color: #999;
}
</style>
<script>
time_day = uptimeStr.substring(5,7);//Mon, 01 Aug 2011 16:25:44 +0800(1467 secs since boot....
time_mon = uptimeStr.substring(9,12);
time_time = uptimeStr.substring(18,20);
dstoffset = '<% nvram_get("time_zone_dstoff"); %>';
var orig_shell_timeout_x = Math.floor(parseInt("<% nvram_get("shell_timeout"); %>")/60);
var orig_enable_acc_restriction = '<% nvram_get("enable_acc_restriction"); %>';
var orig_restrict_rulelist_array = [];
var restrict_rulelist_array = [];
var accounts = [<% get_all_accounts(); %>][0];
for(var i=0; i<accounts.length; i++){
accounts[i] = decodeURIComponent(accounts[i]);
}
if(accounts.length == 0)
accounts = ['<% nvram_get("http_username"); %>'];
var header_info = [<% get_header_info(); %>];
var host_name = header_info[0].host;
if(tmo_support)
var theUrl = "cellspot.router";
else
var theUrl = host_name;
if(sw_mode == 3 || (sw_mode == 4))
theUrl = location.hostname;
var ddns_enable_x = '<% nvram_get("ddns_enable_x"); %>';
var ddns_hostname_x_t = '<% nvram_get("ddns_hostname_x"); %>';
var wan_unit = '<% get_wan_unit(); %>';
if(wan_unit == "0")
var wan_ipaddr = '<% nvram_get("wan0_ipaddr"); %>';
else
var wan_ipaddr = '<% nvram_get("wan1_ipaddr"); %>';
function initial(){
var parseNvramToArray = function(oriNvram) {
var parseArray = [];
var oriNvramRow = decodeURIComponent(oriNvram).split('<');
for(var i = 0; i < oriNvramRow.length; i += 1) {
if(oriNvramRow[i] != "") {
var oriNvramCol = oriNvramRow[i].split('>');
var eachRuleArray = new Array();
for(var j = 0; j < oriNvramCol.length; j += 1) {
eachRuleArray.push(oriNvramCol[j]);
}
parseArray.push(eachRuleArray);
}
}
return parseArray;
};
orig_restrict_rulelist_array = parseNvramToArray('<% nvram_char_to_ascii("","restrict_rulelist"); %>');
restrict_rulelist_array = JSON.parse(JSON.stringify(orig_restrict_rulelist_array));
show_menu();
httpApi.faqURL("1034294", function(url){document.getElementById("faq").href=url;});
httpApi.faqURL("1037370", function(url){document.getElementById("ntp_faq").href=url;});
show_http_clientlist();
display_spec_IP(document.form.http_client.value);
if(reboot_schedule_support){
document.form.reboot_date_x_Sun.checked = getDateCheck(document.form.reboot_schedule.value, 0);
document.form.reboot_date_x_Mon.checked = getDateCheck(document.form.reboot_schedule.value, 1);
document.form.reboot_date_x_Tue.checked = getDateCheck(document.form.reboot_schedule.value, 2);
document.form.reboot_date_x_Wed.checked = getDateCheck(document.form.reboot_schedule.value, 3);
document.form.reboot_date_x_Thu.checked = getDateCheck(document.form.reboot_schedule.value, 4);
document.form.reboot_date_x_Fri.checked = getDateCheck(document.form.reboot_schedule.value, 5);
document.form.reboot_date_x_Sat.checked = getDateCheck(document.form.reboot_schedule.value, 6);
document.form.reboot_time_x_hour.value = getrebootTimeRange(document.form.reboot_schedule.value, 0);
document.form.reboot_time_x_min.value = getrebootTimeRange(document.form.reboot_schedule.value, 1);
document.getElementById('reboot_schedule_enable_tr').style.display = "";
hide_reboot_option('<% nvram_get("reboot_schedule_enable"); %>');
}
else{
document.getElementById('reboot_schedule_enable_tr').style.display = "none";
document.getElementById('reboot_schedule_date_tr').style.display = "none";
document.getElementById('reboot_schedule_time_tr').style.display = "none";
}
setInterval("corrected_timezone();", 5000);
load_timezones();
parse_dstoffset();
document.form.http_passwd2.value = "";
if(svc_ready == "0")
document.getElementById('svc_hint_div').style.display = "";
show_network_monitoring();
if(!HTTPS_support){
document.getElementById("http_auth_table").style.display = "none";
}
else{
hide_https_lanport(document.form.http_enable.value);
}
if(wifi_tog_btn_support || wifi_hw_sw_support || sw_mode == 2 || sw_mode == 4){ // wifi_tog_btn && wifi_hw_sw && hide WPS button behavior under repeater mode
if(cfg_wps_btn_support){
document.getElementById('turn_WPS').style.display = "";
document.form.btn_ez_radiotoggle[1].disabled = true;
document.getElementById('turn_WiFi').style.display = "none";
document.getElementById('turn_WiFi_str').style.display = "none";
document.getElementById('turn_LED').style.display = "";
if(document.form.btn_ez_radiotoggle[2].checked == false)
document.form.btn_ez_radiotoggle[0].checked = true;
}
else{
document.form.btn_ez_radiotoggle[0].disabled = true;
document.form.btn_ez_radiotoggle[1].disabled = true;
document.form.btn_ez_radiotoggle[2].disabled = true;
document.getElementById('btn_ez_radiotoggle_tr').style.display = "none";
}
}
else{
document.getElementById('btn_ez_radiotoggle_tr').style.display = "";
if(cfg_wps_btn_support){
document.getElementById('turn_WPS').style.display = "";
document.getElementById('turn_WiFi').style.display = "";
document.getElementById('turn_LED').style.display = "";
if(document.form.btn_ez_radiotoggle[1].checked == false && document.form.btn_ez_radiotoggle[2].checked == false)
document.form.btn_ez_radiotoggle[0].checked = true;
}
else{
document.getElementById('turn_WPS').style.display = "";
document.getElementById('turn_WiFi').style.display = "";
document.getElementById('turn_LED').disabled = true;
document.getElementById('turn_LED').style.display = "none";
document.getElementById('turn_LED_str').style.display = "none";
if(document.form.btn_ez_radiotoggle[1].checked == false)
document.form.btn_ez_radiotoggle[0].checked = true;
}
}
/* MODELDEP */
if(based_modelid == "AC2900"){ //MODELDEP: AC2900(RT-AC86U)
document.form.btn_ez_radiotoggle[0].disabled = true;
document.form.btn_ez_radiotoggle[1].disabled = true;
document.form.btn_ez_radiotoggle[2].disabled = true;
document.getElementById('btn_ez_radiotoggle_tr').style.display = "none";
}
if(sw_mode != 1){
document.getElementById('misc_http_x_tr').style.display = "none";
hideport(0);
document.form.misc_http_x.disabled = true;
document.form.misc_httpsport_x.disabled = true;
document.form.misc_httpport_x.disabled = true;
document.getElementById("nat_redirect_enable_tr").style.display = "none";
}
else
hideport(document.form.misc_http_x[0].checked);
document.form.http_username.value = '<% nvram_get("http_username"); %>';
if(ssh_support){
check_sshd_enable('<% nvram_get("sshd_enable"); %>');
}
else{
document.getElementById('sshd_enable_tr').style.display = "none";
document.getElementById('sshd_port_tr').style.display = "none";
document.getElementById('sshd_password_tr').style.display = "none";
document.getElementById('auth_keys_tr').style.display = "none";
}
/* MODELDEP */
if(tmo_support || based_modelid == "AC2900"){ //MODELDEP: AC2900(RT-AC86U)
document.getElementById("telnet_tr").style.display = "none";
document.form.telnetd_enable[0].disabled = true;
document.form.telnetd_enable[1].disabled = true;
}
else{
document.getElementById("telnet_tr").style.display = "";
document.form.telnetd_enable[0].disabled = false;
document.form.telnetd_enable[1].disabled = false;
}
document.form.shell_timeout_x.value = orig_shell_timeout_x;
if(pwrsave_support){
document.getElementById("pwrsave_tr").style.display = "";
document.form.pwrsave_mode[0].disabled = false;
document.form.pwrsave_mode[1].disabled = false;
}
else{
document.getElementById("pwrsave_tr").style.display = "none";
document.form.pwrsave_mode[0].disabled = false;
document.form.pwrsave_mode[1].disabled = false;
}
if(hdspindown_support) {
$("#hdd_spindown_table").css("display", "");
change_hddSpinDown($('select[name="usb_idle_enable"]').val());
$('select[name="usb_idle_enable"]').prop("disabled", false);
$('input[name="usb_idle_timeout"]').prop("disabled", false);
}
}
var time_zone_tmp="";
var time_zone_s_tmp="";
var time_zone_e_tmp="";
var time_zone_withdst="";
function applyRule(){
if(validForm()){
var isFromHTTPS = (function(){
if(location.protocol.toLowerCase() == "https:") return true;
else return false;
})();
var isFromWAN = (function(){
var lanIpAddr = '<% nvram_get("lan_ipaddr"); %>';
if(location.hostname == lanIpAddr) return false;
else if(location.hostname == "router.asus.com") return false;
else if(location.hostname == "repeater.asus.com") return false;
else if(location.hostname == "cellspot.asus.com") return false;
else return true;
})();
var restart_firewall_flag = false;
var restart_httpd_flag = false;
var old_fw_tmp_value = ""; //for old version fw
var tmp_value = "";
for(var i = 0; i < restrict_rulelist_array.length; i += 1) {
if(restrict_rulelist_array[i].length != 0) {
old_fw_tmp_value += "<";
tmp_value += "<";
for(var j = 0; j < restrict_rulelist_array[i].length; j += 1) {
tmp_value += restrict_rulelist_array[i][j];
if( (j + 1) != restrict_rulelist_array[i].length)
tmp_value += ">";
if(j == 1) //IP, for old version fw
old_fw_tmp_value += restrict_rulelist_array[i][j];
}
}
}
var getRadioItemCheck = function(obj) {
var checkValue = "";
var radioLength = obj.length;
for(var i = 0; i < radioLength; i += 1) {
if(obj[i].checked) {
checkValue = obj[i].value;
break;
}
}
return checkValue;
};
document.form.http_client.value = getRadioItemCheck(document.form.http_client_radio); //for old version fw
document.form.http_clientlist.value = old_fw_tmp_value; //for old version fw
document.form.enable_acc_restriction.value = getRadioItemCheck(document.form.http_client_radio);
document.form.restrict_rulelist.value = tmp_value;
if(document.form.restrict_rulelist.value == "" && document.form.http_client_radio[0].checked == 1){
alert("<#222#>");
document.form.http_client_ip_x_0.focus();
return false;
}
if((document.form.enable_acc_restriction.value != orig_enable_acc_restriction) || (restrict_rulelist_array.toString() != orig_restrict_rulelist_array.toString()))
restart_firewall_flag = true;
if(document.form.http_passwd2.value.length > 0){
document.form.http_passwd.value = document.form.http_passwd2.value;
document.form.http_passwd.disabled = false;
}
if(document.form.time_zone_select.value.search("DST") >= 0 || document.form.time_zone_select.value.search("TDT") >= 0){ // DST area
time_zone_tmp = document.form.time_zone_select.value.split("_"); //0:time_zone 1:serial number
time_zone_s_tmp = "M"+document.form.dst_start_m.value+"."+document.form.dst_start_w.value+"."+document.form.dst_start_d.value+"/"+document.form.dst_start_h.value;
time_zone_e_tmp = "M"+document.form.dst_end_m.value+"."+document.form.dst_end_w.value+"."+document.form.dst_end_d.value+"/"+document.form.dst_end_h.value;
document.form.time_zone_dstoff.value=time_zone_s_tmp+","+time_zone_e_tmp;
document.form.time_zone.value = document.form.time_zone_select.value;
}else{
document.form.time_zone.value = document.form.time_zone_select.value;
}
document.form.shell_timeout.value = parseInt(document.form.shell_timeout_x.value)*60;
if(document.form.misc_http_x[1].checked == true){
document.form.misc_httpport_x.disabled = true;
document.form.misc_httpsport_x.disabled = true;
}
if(document.form.misc_http_x[0].checked == true
&& document.form.http_enable[0].selected == true){
document.form.misc_httpsport_x.disabled = true;
}
if(document.form.misc_http_x[0].checked == true
&& document.form.http_enable[1].selected == true){
document.form.misc_httpport_x.disabled = true;
}
if(document.form.http_lanport.value != '<% nvram_get("http_lanport"); %>'
|| document.form.https_lanport.value != '<% nvram_get("https_lanport"); %>'
|| document.form.http_enable.value != '<% nvram_get("http_enable"); %>'
|| document.form.misc_httpport_x.value != '<% nvram_get("misc_httpport_x"); %>'
|| document.form.misc_httpsport_x.value != '<% nvram_get("misc_httpsport_x"); %>'
){
restart_httpd_flag = true;
if(document.form.http_enable.value == "0"){ //HTTP
if(isFromWAN)
document.form.flag.value = "http://" + location.hostname + ":" + document.form.misc_httpport_x.value;
else if (document.form.http_lanport.value)
document.form.flag.value = "http://" + location.hostname + ":" + document.form.http_lanport.value;
else
document.form.flag.value = "http://" + location.hostname;
}
else if(document.form.http_enable.value == "1"){ //HTTPS
if(isFromWAN)
document.form.flag.value = "https://" + location.hostname + ":" + document.form.misc_httpsport_x.value;
else
document.form.flag.value = "https://" + location.hostname + ":" + document.form.https_lanport.value;
}
else{ //BOTH
if(isFromHTTPS){
if(isFromWAN)
document.form.flag.value = "https://" + location.hostname + ":" + document.form.misc_httpsport_x.value;
else
document.form.flag.value = "https://" + location.hostname + ":" + document.form.https_lanport.value;
}else{
if(isFromWAN)
document.form.flag.value = "http://" + location.hostname + ":" + document.form.misc_httpport_x.value;
else if (document.form.http_lanport.value)
document.form.flag.value = "http://" + location.hostname + ":" + document.form.http_lanport.value;
else
document.form.flag.value = "http://" + location.hostname;
}
}
}
if(document.form.btn_ez_radiotoggle[1].disabled == false && document.form.btn_ez_radiotoggle[1].checked == true){
document.form.btn_ez_radiotoggle.value=1;
document.form.btn_ez_mode.value=0;
}
else if(document.form.btn_ez_radiotoggle[2].disabled == false && document.form.btn_ez_radiotoggle[2].checked == true){
document.form.btn_ez_radiotoggle.value=0;
document.form.btn_ez_mode.value=1;
}
else{
document.form.btn_ez_radiotoggle.value=0;
document.form.btn_ez_mode.value=0;
}
if(reboot_schedule_support){
updateDateTime();
}
if(document.form.wandog_enable_chk.checked)
document.form.wandog_enable.value = "1";
else
document.form.wandog_enable.value = "0";
if(document.form.dns_probe_chk.checked)
document.form.dns_probe.value = "1";
else
document.form.dns_probe.value = "0";
showLoading();
var action_script_tmp = "restart_time;restart_upnp;";
if(hdspindown_support)
action_script_tmp += "restart_usb_idle;";
if(restart_httpd_flag)
action_script_tmp += "restart_httpd;";
if(restart_firewall_flag)
action_script_tmp += "restart_firewall;";
if(pwrsave_support)
action_script_tmp += "pwrsave;";
if(needReboot){
action_script_tmp = "reboot";
document.form.action_wait.value = httpApi.hookGet("get_default_reboot_time");
}
document.form.action_script.value = action_script_tmp;
document.form.submit();
}
}
function validForm(){
showtext(document.getElementById("alert_msg1"), "");
showtext(document.getElementById("alert_msg2"), "");
if(document.form.http_username.value.length == 0){
showtext(document.getElementById("alert_msg1"), "<#181#>");
document.form.http_username.focus();
document.form.http_username.select();
return false;
}
else{
var alert_str = validator.hostName(document.form.http_username);
if(alert_str != ""){
showtext(document.getElementById("alert_msg1"), alert_str);
document.getElementById("alert_msg1").style.display = "";
document.form.http_username.focus();
document.form.http_username.select();
return false;
}else{
document.getElementById("alert_msg1").style.display = "none";
}
document.form.http_username.value = trim(document.form.http_username.value);
if(document.form.http_username.value == "root"
|| document.form.http_username.value == "guest"
|| document.form.http_username.value == "anonymous"
){
showtext(document.getElementById("alert_msg1"), "<#660#>");
document.getElementById("alert_msg1").style.display = "";
document.form.http_username.focus();
document.form.http_username.select();
return false;
}
else if(accounts.getIndexByValue(document.form.http_username.value) > 0
&& document.form.http_username.value != accounts[0]){
showtext(document.getElementById("alert_msg1"), "<#184#>");
document.getElementById("alert_msg1").style.display = "";
document.form.http_username.focus();
document.form.http_username.select();
return false;
}else{
document.getElementById("alert_msg1").style.display = "none";
}
}
if(document.form.http_passwd2.value.length > 0 && document.form.http_passwd2.value.length < 5){
showtext(document.getElementById("alert_msg2"),"* <#229#>");
document.form.http_passwd2.focus();
document.form.http_passwd2.select();
return false;
}
if(document.form.http_passwd2.value != document.form.v_password2.value){
showtext(document.getElementById("alert_msg2"),"* <#186#>");
if(document.form.http_passwd2.value.length <= 0){
document.form.http_passwd2.focus();
document.form.http_passwd2.select();
}else{
document.form.v_password2.focus();
document.form.v_password2.select();
}
return false;
}
if(is_KR_sku){ /* MODELDEP by Territory Code */
if(document.form.http_passwd2.value.length > 0 || document.form.http_passwd2.value.length > 0){
if(!validator.string_KR(document.form.http_passwd2)){
document.form.http_passwd2.focus();
document.form.http_passwd2.select();
return false;
}
}
}
else{
if(!validator.string(document.form.http_passwd2)){
document.form.http_passwd2.focus();
document.form.http_passwd2.select();
return false;
}
}
if(document.form.http_passwd2.value == '<% nvram_default_get("http_passwd"); %>'){
showtext(document.getElementById("alert_msg2"),"* <#382#>");
document.form.http_passwd2.focus();
document.form.http_passwd2.select();
return false;
}
var is_common_string = check_common_string(document.form.http_passwd2.value, "httpd_password");
if(document.form.http_passwd2.value.length > 0 && is_common_string){
if(!confirm("<#218#>")){
document.form.http_passwd2.focus();
document.form.http_passwd2.select();
return false;
}
}
if(hdspindown_support) {
if($('select[name="usb_idle_enable"]').val() == 1) {
$('input[name="usb_idle_timeout"]').prop("disabled", false);
if (!validator.range($('input[name="usb_idle_timeout"]')[0], 60, 3600))
return false;
}
else {
$('input[name="usb_idle_timeout"]').prop("disabled", true);
}
}
if((document.form.time_zone_select.value.search("DST") >= 0 || document.form.time_zone_select.value.search("TDT") >= 0) // DST area
&& document.form.dst_start_m.value == document.form.dst_end_m.value
&& document.form.dst_start_w.value == document.form.dst_end_w.value
&& document.form.dst_start_d.value == document.form.dst_end_d.value){
alert("<#1640#>"); //At same day
document.form.dst_start_m.focus();
return false;
}
if(document.form.sshd_enable.value != "0" && document.form.sshd_pass[1].checked && document.form.sshd_authkeys.value == ""){
alert("<#222#>");
document.form.sshd_authkeys.focus();
return false;
}
if (!validator.range(document.form.http_lanport, 1, 65535))
/*return false;*/ document.form.http_lanport = 80;
if (HTTPS_support && !validator.range(document.form.https_lanport, 1, 65535) && !tmo_support)
return false;
if (document.form.misc_http_x[0].checked) {
if (!validator.range(document.form.misc_httpport_x, 1024, 65535))
return false;
if (HTTPS_support && !validator.range(document.form.misc_httpsport_x, 1024, 65535))
return false;
}
else{
document.form.misc_httpport_x.value = '<% nvram_get("misc_httpport_x"); %>';
document.form.misc_httpsport_x.value = '<% nvram_get("misc_httpsport_x"); %>';
}
if(document.form.sshd_enable.value != 0){
if (!validator.range(document.form.sshd_port, 1, 65535))
return false;
}
else{
document.form.sshd_port.disabled = true;
}
if(!validator.rangeAllowZero(document.form.shell_timeout_x, 10, 999, orig_shell_timeout_x))
return false;
if(!document.form.misc_httpport_x.disabled &&
isPortConflict(document.form.misc_httpport_x.value)){
alert(isPortConflict(document.form.misc_httpport_x.value));
document.form.misc_httpport_x.focus();
return false;
}
else if(!document.form.misc_httpsport_x.disabled &&
isPortConflict(document.form.misc_httpsport_x.value) && HTTPS_support){
alert(isPortConflict(document.form.misc_httpsport_x.value));
document.form.misc_httpsport_x.focus();
return false;
}
else if(isPortConflict(document.form.https_lanport.value) && HTTPS_support && !tmo_support){
alert(isPortConflict(document.form.https_lanport.value));
document.form.https_lanport.focus();
return false;
}
else if(document.form.misc_httpsport_x.value == document.form.misc_httpport_x.value && HTTPS_support){
alert("<#1797#>");
document.form.misc_httpsport_x.focus();
return false;
}
else if(!validator.rangeAllowZero(document.form.http_autologout, 10, 999, '<% nvram_get("http_autologout"); %>'))
return false;
if(reboot_schedule_support){
if(!document.form.reboot_date_x_Sun.checked && !document.form.reboot_date_x_Mon.checked &&
!document.form.reboot_date_x_Tue.checked && !document.form.reboot_date_x_Wed.checked &&
!document.form.reboot_date_x_Thu.checked && !document.form.reboot_date_x_Fri.checked &&
!document.form.reboot_date_x_Sat.checked && document.form.reboot_schedule_enable_x[0].checked)
{
alert(Untranslated.filter_lw_date_valid);
document.form.reboot_date_x_Sun.focus();
return false;
}
}
if(document.form.http_passwd2.value.length > 0) //password setting changed
alert("<#1597#>");
var WebUI_selected=0
if(document.form.http_client_radio[0].checked && restrict_rulelist_array.length >0){ //Allow only specified IP address
for(var x=0;x<restrict_rulelist_array.length;x++){
if(restrict_rulelist_array[x][0] == 1 && //enabled rule && Web UI included
(restrict_rulelist_array[x][2] == 1 || restrict_rulelist_array[x][2] == 3 || restrict_rulelist_array[x][2] == 5 || restrict_rulelist_array[x][2] == 7)){
WebUI_selected++;
}
}
if(WebUI_selected <= 0){
alert("Please select at least one Web UI of Access Type and enable it in [Allow only specified IP address]"); //Untranslated 2017/08
document.form.http_client_ip_x_0.focus();
return false;
}
}
return true;
}
function done_validating(action){
refreshpage();
}
function corrected_timezone(){
var today = new Date();
var StrIndex;
var timezone = uptimeStr_update.substring(26,31);
if(today.toString().lastIndexOf("-") > 0)
StrIndex = today.toString().lastIndexOf("-");
else if(today.toString().lastIndexOf("+") > 0)
StrIndex = today.toString().lastIndexOf("+");
if(StrIndex > 0){
if(timezone != today.toString().substring(StrIndex, StrIndex+5)){
document.getElementById("timezone_hint").style.display = "block";
document.getElementById("timezone_hint").innerHTML = "* <#1995#>";
}
else
return;
}
else
return;
}
var timezones = [
["UTC12", "(GMT-12:00) <#2645#>"],
["UTC11", "(GMT-11:00) <#2646#>"],
["UTC10", "(GMT-10:00) <#2647#>"],
["NAST9DST", "(GMT-09:00) <#2648#>"],
["PST8DST", "(GMT-08:00) <#2649#>"],
["MST7DST_1", "(GMT-07:00) <#2650#>"],
["MST7_2", "(GMT-07:00) <#2651#>"],
["MST7DST_3", "(GMT-07:00) <#2652#>"],
["CST6_2", "(GMT-06:00) <#2653#>"],
["CST6DST_3", "(GMT-06:00) <#2654#>"],
["CST6DST_3_1", "(GMT-06:00) <#2655#>"],
["UTC6DST", "(GMT-06:00) <#2656#>"],
["EST5DST", "(GMT-05:00) <#2657#>"],
["UTC5_1", "(GMT-05:00) <#2658#>"],
["UTC5_2", "(GMT-05:00) <#2659#>"],
["AST4DST", "(GMT-04:00) <#2660#>"],
["UTC4_1", "(GMT-04:00) <#2661#>"],
["UTC4_2", "(GMT-04:00) <#2662#>"],
["UTC4DST_2", "(GMT-04:00) <#2663#>"],
["NST3.30DST", "(GMT-03:30) <#2664#>"],
["EBST3DST_1", "(GMT-03:00) <#2665#>"],
["UTC3", "(GMT-03:00) <#2666#>"],
["EBST3DST_2", "(GMT-03:00) <#2667#>"],
["UTC2", "(GMT-02:00) <#2668#>"],
["EUT1DST", "(GMT-01:00) <#2669#>"],
["UTC1", "(GMT-01:00) <#2670#>"],
["GMT0", "(GMT) <#2671#>"],
["GMT0DST_1", "(GMT) <#2672#>"],
["GMT0DST_2", "(GMT) <#2673#>"],
["GMT0_2", "(GMT) <#2674#>"],
["UTC-1DST_1", "(GMT+01:00) <#2675#>"],
["UTC-1DST_1_1","(GMT+01:00) <#2676#>"],
["UTC-1DST_1_2", "(GMT+01:00) <#2677#>"],
["UTC-1DST_2", "(GMT+01:00) <#2678#>"],
["MET-1DST", "(GMT+01:00) <#2679#>"],
["MET-1DST_1", "(GMT+01:00) <#2681#>"],
["MEZ-1DST", "(GMT+01:00) <#2682#>"],
["MEZ-1DST_1", "(GMT+01:00) <#2683#>"],
["UTC-1_3", "(GMT+01:00) <#2684#>"],
["UTC-2DST", "(GMT+02:00) <#2685#>"],
["UTC-2DST_3", "(GMT+02:00) <#2680#>"],
["EST-2", "(GMT+02:00) <#2686#>"],
["UTC-2DST_4", "(GMT+02:00) <#2687#>"],
["UTC-2DST_2", "(GMT+02:00) <#2690#>"],
["IST-2DST", "(GMT+02:00) <#2691#>"],
["EET-2DST", "(GMT+02:00) <#2693#>"],
["UTC-2_1", "(GMT+02:00) <#2689#>"],
["SAST-2", "(GMT+02:00) <#2692#>"],
["UTC-3_1", "(GMT+03:00) <#2696#>"],
["UTC-3_2", "(GMT+03:00) <#2697#>"],
["UTC-3_3", "(GMT+03:00) <#2688#>"],
["UTC-3_4", "(GMT+03:00) <#2694#>"],
["UTC-3_5", "(GMT+03:00) <#2695#>"],
["IST-3", "(GMT+03:00) <#2698#>"],
["UTC-3_6", "(GMT+03:00) <#2699#>"],
["UTC-3.30DST", "(GMT+03:30) <#2700#>"],
["UTC-4_1", "(GMT+04:00) <#2701#>"],
["UTC-4_5", "(GMT+04:00) <#2703#>"],
["UTC-4_4", "(GMT+04:00) <#2702#>"],
["UTC-4_6", "(GMT+04:00) <#2704#>"],
["UTC-4.30", "(GMT+04:30) <#2705#>"],
["UTC-5", "(GMT+05:00) <#2707#>"],
["UTC-5_1", "(GMT+05:00) <#2706#>"],
["UTC-5.30_2", "(GMT+05:30) <#2708#>"],
["UTC-5.30_1", "(GMT+05:30) <#2709#>"],
["UTC-5.30", "(GMT+05:30) <#2712#>"],
["UTC-5.45", "(GMT+05:45) <#2710#>"],
["RFT-6", "(GMT+06:00) <#2713#>"],
["UTC-6", "(GMT+06:00) <#2711#>"],
["UTC-6_2", "(GMT+06:00) <#2716#>"],
["UTC-6.30", "(GMT+06:30) <#2714#>"],
["UTC-7", "(GMT+07:00) <#2715#>"],
["UTC-7_2", "(GMT+07:00) <#2717#>"],
["CST-8", "(GMT+08:00) <#2718#>"],
["CST-8_1", "(GMT+08:00) <#2719#>"],
["SST-8", "(GMT+08:00) <#2720#>"],
["CCT-8", "(GMT+08:00) <#2721#>"],
["WAS-8", "(GMT+08:00) <#2722#>"],
["UTC-8", "(GMT+08:00) <#2723#>"],
["UTC-8_1", "(GMT+08:00) <#2724#>"],
["UTC-9_1", "(GMT+09:00) <#2725#>"],
["UTC-9_3", "(GMT+09:00) <#2727#>"],
["JST", "(GMT+09:00) <#2726#>"],
["CST-9.30", "(GMT+09:30) <#2728#>"],
["UTC-9.30DST", "(GMT+09:30) <#2729#>"],
["UTC-10DST_1", "(GMT+10:00) <#2730#>"],
["UTC-10_2", "(GMT+10:00) <#2731#>"],
["UTC-10_4", "(GMT+10:00) <#2733#>"],
["TST-10TDT", "(GMT+10:00) <#2732#>"],
["UTC-10_6", "(GMT+10:00) <#2734#>"],
["UTC-11", "(GMT+11:00) <#2735#>"],
["UTC-11_1", "(GMT+11:00) <#2736#>"],
["UTC-11_3", "(GMT+11:00) <#2742#>"],
["UTC-11_4", "(GMT+11:00) <#2738#>"],
["UTC-12", "(GMT+12:00) <#2737#>"],
["UTC-12_2", "(GMT+12:00) <#2741#>"],
["NZST-12DST", "(GMT+12:00) <#2739#>"],
["UTC-13", "(GMT+13:00) <#2740#>"]];
function load_timezones(){
free_options(document.form.time_zone_select);
for(var i = 0; i < timezones.length; i++){
add_option(document.form.time_zone_select,
timezones[i][1], timezones[i][0],
(document.form.time_zone.value == timezones[i][0]));
}
select_time_zone();
}
var dst_month = new Array("", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12");
var dst_week = new Array("", "1st", "2nd", "3rd", "4th", "5th");
var dst_day = new Array("<#1308#>", "<#1306#>", "<#1310#>", "<#1311#>", "<#1309#>", "<#1305#>", "<#1307#>");
var dst_hour = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
"13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23");
var dstoff_start_m,dstoff_start_w,dstoff_start_d,dstoff_start_h;
var dstoff_end_m,dstoff_end_w,dstoff_end_d,dstoff_end_h;
function parse_dstoffset(){ //Mm.w.d/h,Mm.w.d/h
if(dstoffset){
var dstoffset_startend = dstoffset.split(",");
if(dstoffset_startend[0] != "" && dstoffset_startend[0] != undefined){
var dstoffset_start = trim(dstoffset_startend[0]);
var dstoff_start = dstoffset_start.split(".");
dstoff_start_m = parseInt(dstoff_start[0].substring(1));
if(check_range(dstoff_start_m,1,12)){
document.form.dst_start_m.value = dstoff_start_m;
}
if(dstoff_start[1] != "" && dstoff_start[1] != undefined){
dstoff_start_w = parseInt(dstoff_start[1]);
if(check_range(dstoff_start_w,1,5)){
document.form.dst_start_w.value = dstoff_start_w;
}
}
if(dstoff_start[2] != "" && dstoff_start[2] != undefined){
dstoff_start_d = parseInt(dstoff_start[2].split("/")[0]);
if(check_range(dstoff_start_d,0,6)){
document.form.dst_start_d.value = dstoff_start_d;
}
dstoff_start_h = parseInt(dstoff_start[2].split("/")[1]);
if(check_range(dstoff_start_h,0,23)){
document.form.dst_start_h.value = dstoff_start_h;
}
}
}
if(dstoffset_startend[1] != "" && dstoffset_startend[1] != undefined){
var dstoffset_end = trim(dstoffset_startend[1]);
var dstoff_end = dstoffset_end.split(".");
dstoff_end_m = parseInt(dstoff_end[0].substring(1));
if(check_range(dstoff_end_m,1,12)){
document.form.dst_end_m.value = dstoff_end_m;
}
if(dstoff_end[1] != "" && dstoff_end[1] != undefined){
dstoff_end_w = parseInt(dstoff_end[1]);
if(check_range(dstoff_end_w,1,5)){
document.form.dst_end_w.value = dstoff_end_w;
}
}
if(dstoff_end[2] != "" && dstoff_end[2] != undefined){
dstoff_end_d = parseInt(dstoff_end[2].split("/")[0]);
if(check_range(dstoff_end_d,0,6)){
document.form.dst_end_d.value = dstoff_end_d;
}
dstoff_end_h = parseInt(dstoff_end[2].split("/")[1]);
if(check_range(dstoff_end_h,0,23)){
document.form.dst_end_h.value = dstoff_end_h;
}
}
}
}
}
function check_range(obj, first, last){
if(obj != "NaN" && first <= obj && obj <= last)
return true;
else
return false;
}
function hide_https_lanport(_value){
if(tmo_support){
document.getElementById("https_lanport").style.display = "none";
return false;
}
if(sw_mode == '1' || sw_mode == '2'){
var https_lanport_num = "<% nvram_get("https_lanport"); %>";
document.getElementById("https_lanport").style.display = (_value == "0") ? "none" : "";
document.form.https_lanport.value = "<% nvram_get("https_lanport"); %>";
document.getElementById("https_access_page").innerHTML = "<#1796#> ";
document.getElementById("https_access_page").innerHTML += "<a href=\"https://"+theUrl+":"+https_lanport_num+"\" target=\"_blank\" style=\"color:#FC0;text-decoration: underline; font-family:Lucida Console;\">http<span>s</span>://"+theUrl+"<span>:"+https_lanport_num+"</span></a>";
document.getElementById("https_access_page").style.display = (_value == "0") ? "none" : "";
}
else{
document.getElementById("https_access_page").style.display = 'none';
}
}
function show_http_clientlist(){
var code = "";
code +='<table width="100%" border="1" cellspacing="0" cellpadding="4" align="center" class="list_table" id="http_clientlist_table">';
if(restrict_rulelist_array.length == 0) {
code +='<tr><td style="color:#FFCC00;"><#1853#></td></tr>';
}
else {
var transformNumToText = function(restrict_type) {
var bit_text_array = ["", "Web UI", "SSH", "Telnet"];
var type_text = "";
for(var i = 1; restrict_type != 0 && i <= 4; i += 1) {
if(restrict_type & 1) {
if(type_text == "")
type_text += bit_text_array[i];
else
type_text += ", " + bit_text_array[i];
}
restrict_type = restrict_type >> 1;
}
return type_text;
};
for(var i = 0; i < restrict_rulelist_array.length; i += 1) {
if(restrict_rulelist_array[i][0] == "1")
code += '<tr style="color:#FFFFFF;">';
else
code += '<tr style="color:#A0A0A0;">';
code += '<td width="10%">';
if(restrict_rulelist_array[i][0] == "1")
code += '<div class="check" onclick="control_rule_status(this);"><div style="width:16px;height:16px;margin: 3px auto" class="icon_check"></div></div>';
else
code += '<div class="cancel" style="" onclick="control_rule_status(this);"><div style="width:16px;height:16px;margin: 3px auto" class="icon_cancel"></div></div>';
code += '</td>';
code += '<td width="40%">';
code += restrict_rulelist_array[i][1];
code += "</td>";
code += '<td width="40%">';
code += transformNumToText(restrict_rulelist_array[i][2]);
code += "</td>";
code += '<td width="10%">';
code += '<div class="remove" style="margin:0 auto" onclick="deleteRow(this);">';
code += "</td>";
code += '</tr>';
}
}
code +='</table>';
document.getElementById("http_clientlist_Block").innerHTML = code;
}
function check_Timefield_checkbox(){ // To check Date checkbox checked or not and control Time field disabled or not
if( document.form.reboot_date_x_Sun.checked == true
|| document.form.reboot_date_x_Mon.checked == true
|| document.form.reboot_date_x_Tue.checked == true
|| document.form.reboot_date_x_Wed.checked == true
|| document.form.reboot_date_x_Thu.checked == true
|| document.form.reboot_date_x_Fri.checked == true
|| document.form.reboot_date_x_Sat.checked == true ){
inputCtrl(document.form.reboot_time_x_hour,1);
inputCtrl(document.form.reboot_time_x_min,1);
document.form.reboot_schedule.disabled = false;
}
else{
inputCtrl(document.form.reboot_time_x_hour,0);
inputCtrl(document.form.reboot_time_x_min,0);
document.form.reboot_schedule.disabled = true;
document.getElementById('reboot_schedule_time_tr').style.display ="";
}
}
function deleteRow(r){
var i=r.parentNode.parentNode.rowIndex;
document.getElementById('http_clientlist_table').deleteRow(i);
restrict_rulelist_array.splice(i,1);
if(restrict_rulelist_array.length == 0)
show_http_clientlist();
}
function addRow(obj, upper){
if('<% nvram_get("http_client"); %>' != "1")
document.form.http_client_radio[0].checked = true;
var rule_num = restrict_rulelist_array.length;
if(rule_num >= upper){
alert("<#1911#> " + upper + " <#1912#>");
return false;
}
if(obj.value == ""){
alert("<#222#>");
obj.focus();
obj.select();
return false;
}
else if(validator.validIPForm(obj, 2) != true){
return false;
}
var access_type_value = 0;
$(".access_type").each(function() {
if(this.checked)
access_type_value += parseInt($(this).val());
});
if(access_type_value == 0) {
alert("Please select at least one Access Type.");/*untranslated*/
return false;
}
else{
var newRuleArray = new Array();
newRuleArray.push("1");
newRuleArray.push(obj.value.trim());
newRuleArray.push(access_type_value.toString());
var newRuleArray_tmp = new Array();
newRuleArray_tmp = newRuleArray.slice();
newRuleArray_tmp.splice(0, 1);
newRuleArray_tmp.splice(1, 1);
if(restrict_rulelist_array.length > 0) {
for(var i = 0; i < restrict_rulelist_array.length; i += 1) {
var restrict_rulelist_array_tmp = restrict_rulelist_array[i].slice();
restrict_rulelist_array_tmp.splice(0, 1);
restrict_rulelist_array_tmp.splice(1, 1);
if(newRuleArray_tmp.toString() == restrict_rulelist_array_tmp.toString()) { //compare IP
alert("<#1905#>");
return false;
}
}
}
restrict_rulelist_array.push(newRuleArray);
obj.value = "";
$(".access_type").each(function() {
if(this.checked)
$(this).prop('checked', false);
});
show_http_clientlist();
if($("#selAll").hasClass("all_enable"))
$("#selAll").removeClass("all_enable").addClass("all_disable");
}
}
function keyBoardListener(evt){
var nbr = (window.evt)?event.keyCode:event.which;
if(nbr == 13)
addRow(document.form.http_client_ip_x_0, 4);
}
function setClientIP(ipaddr){
document.form.http_client_ip_x_0.value = ipaddr;
hideClients_Block();
}
function hideClients_Block(){
document.getElementById("pull_arrow").src = "/images/arrow-down.gif";
document.getElementById('ClientList_Block_PC').style.display='none';
}
function pullLANIPList(obj){
var element = document.getElementById('ClientList_Block_PC');
var isMenuopen = element.offsetWidth > 0 || element.offsetHeight > 0;
if(isMenuopen == 0){
obj.src = "/images/arrow-top.gif"
element.style.display = 'block';
document.form.http_client_ip_x_0.focus();
}
else
hideClients_Block();
}
function hideport(flag){
document.getElementById("accessfromwan_port").style.display = (flag == 1) ? "" : "none";
if(!HTTPS_support){
document.getElementById("NSlookup_help_for_WAN_access").style.display = (flag == 1) ? "" : "none";
var orig_str = document.getElementById("access_port_title").innerHTML;
document.getElementById("access_port_title").innerHTML = orig_str.replace(/HTTPS/, "HTTP");
document.getElementById("http_port").style.display = (flag == 1) ? "" : "none";
}
else{
document.getElementById("WAN_access_hint").style.display = (flag == 1) ? "" : "none";
document.getElementById("wan_access_url").style.display = (flag == 1) ? "" : "none";
change_url(document.form.misc_httpsport_x.value, "https_wan");
document.getElementById("https_port").style.display = (flag == 1) ? "" : "none";
}
}
var autoChange = false;
function enable_wan_access(flag){
if(HTTPS_support){
if(flag == 1){
if(document.form.http_enable.value == "0"){
document.form.http_enable.selectedIndex = 2;
autoChange = true;
hide_https_lanport(document.form.http_enable.value);
}
}
else{
var effectApps = [];
if(app_support) effectApps.push("<#3370#>");
if(alexa_support) effectApps.push("<#3371#>");
var original_misc_http_x = httpApi.nvramGet(["misc_http_x"]).misc_http_x;
var RemoteAccessHint = "<#3369#>".replace("$Apps$", effectApps.join(", "));
if(original_misc_http_x == '1' && effectApps.length != 0){
if(!confirm(RemoteAccessHint)){
document.form.misc_http_x[0].checked = true;
hideport(1);
enable_wan_access(1);
return false;
}
}
if(autoChange){
document.form.http_enable.selectedIndex = 0;
autoChange = false;
hide_https_lanport(document.form.http_enable.value);
}
}
}
}
function check_wan_access(http_enable){
if(http_enable == "0" && document.form.misc_http_x[0].checked == true){ //While Accesss from WAN enabled, not allow to set HTTP only
alert("When \"Web Access from WAN\" is enabled, HTTPS must be enabled.");
document.form.http_enable.selectedIndex = 2;
hide_https_lanport(document.form.http_enable.value);
}
}
function change_url(num, flag){
if(flag == 'https_lan'){
var https_lanport_num_new = num;
document.getElementById("https_access_page").innerHTML = "<#1796#> ";
document.getElementById("https_access_page").innerHTML += "<a href=\"https://"+theUrl+":"+https_lanport_num_new+"\" target=\"_blank\" style=\"color:#FC0;text-decoration: underline; font-family:Lucida Console;\">http<span>s</span>://"+theUrl+"<span>:"+https_lanport_num_new+"</span></a>";
}
else if(flag == 'https_wan'){
var https_wanport = num;
var host_addr = "";
if(ddns_enable_x == "1" && ddns_hostname_x_t.length != 0)
host_addr = ddns_hostname_x_t;
else
host_addr = wan_ipaddr;
document.getElementById("wan_access_url").innerHTML = "<#1796#> ";
document.getElementById("wan_access_url").innerHTML += "<a href=\"https://"+host_addr+":"+https_wanport+"\" target=\"_blank\" style=\"color:#FC0;text-decoration: underline; font-family:Lucida Console;\">http<span>s</span>://"+host_addr+"<span>:"+https_wanport+"</span></a>";
}
}
/* password item show or not */
function pass_checked(obj){
switchType(obj, document.form.show_pass_1.checked, true);
}
function select_time_zone(){
if(document.form.time_zone_select.value.search("DST") >= 0 || document.form.time_zone_select.value.search("TDT") >= 0){ //DST area
document.form.time_zone_dst.value=1;
document.getElementById("dst_changes_start").style.display="";
document.getElementById("dst_changes_end").style.display="";
document.getElementById("dst_start").style.display="";
document.getElementById("dst_end").style.display="";
}
else{
document.form.time_zone_dst.value=0;
document.getElementById("dst_changes_start").style.display="none";
document.getElementById("dst_changes_end").style.display="none";
document.getElementById("dst_start").style.display="none";
document.getElementById("dst_end").style.display="none";
}
}
function clean_scorebar(obj){
if(obj.value == "")
document.getElementById("scorebarBorder").style.display = "none";
}
function check_sshd_enable(obj_value){
if(obj_value != 0){
document.getElementById('sshd_port_tr').style.display = "";
document.getElementById('sshd_password_tr').style.display = "";
document.getElementById('auth_keys_tr').style.display = "";
}
else{
document.getElementById('sshd_port_tr').style.display = "none";
document.getElementById('sshd_password_tr').style.display = "none";
document.getElementById('auth_keys_tr').style.display = "none";
}
}
/*function sshd_remote_access(obj_value){
if(obj_value == 1){
document.getElementById('remote_access_port_tr').style.display = "";
}
else{
document.getElementById('remote_access_port_tr').style.display = "none";
}
}*/
/*function sshd_forward(obj_value){
if(obj_value == 1){
document.getElementById('remote_forwarding_port_tr').style.display = "";
}
else{
document.getElementById('remote_forwarding_port_tr').style.display = "none";
}
}*/
function display_spec_IP(flag){
if(flag == 0){
document.getElementById("http_client_table").style.display = "none";
document.getElementById("http_clientlist_Block").style.display = "none";
}
else{
document.getElementById("http_client_table").style.display = "";
document.getElementById("http_clientlist_Block").style.display = "";
setTimeout("showDropdownClientList('setClientIP', 'ip', 'all', 'ClientList_Block_PC', 'pull_arrow', 'online');", 1000);
}
}
function hide_reboot_option(flag){
document.getElementById("reboot_schedule_date_tr").style.display = (flag == 1) ? "" : "none";
document.getElementById("reboot_schedule_time_tr").style.display = (flag == 1) ? "" : "none";
if(flag==1)
check_Timefield_checkbox();
}
function getrebootTimeRange(str, pos)
{
if (pos == 0)
return str.substring(7,9);
else if (pos == 1)
return str.substring(9,11);
}
function setrebootTimeRange(rd, rh, rm)
{
return(rd.value+rh.value+rm.value);
}
function updateDateTime()
{
if(document.form.reboot_schedule_enable_x[0].checked){
document.form.reboot_schedule_enable.value = "1";
document.form.reboot_schedule.disabled = false;
document.form.reboot_schedule.value = setDateCheck(
document.form.reboot_date_x_Sun,
document.form.reboot_date_x_Mon,
document.form.reboot_date_x_Tue,
document.form.reboot_date_x_Wed,
document.form.reboot_date_x_Thu,
document.form.reboot_date_x_Fri,
document.form.reboot_date_x_Sat);
document.form.reboot_schedule.value = setrebootTimeRange(
document.form.reboot_schedule,
document.form.reboot_time_x_hour,
document.form.reboot_time_x_min);
}
else
document.form.reboot_schedule_enable.value = "0";
}
function paste_password(){
document.form.show_pass_1.checked = true;
pass_checked(document.form.http_passwd2);
pass_checked(document.form.v_password2);
}
function control_rule_status(obj) {
var $itemObj = $(obj);
var $trObj = $itemObj.closest('tr');
var row_idx = $trObj.index();
if($itemObj.hasClass("cancel")) {
$itemObj.removeClass("cancel").addClass("check");
$itemObj.children().removeClass("icon_cancel").addClass("icon_check");
restrict_rulelist_array[row_idx][0] = "1";
$trObj.css({"color" : "#FFFFFF"});
}
else {
$itemObj.removeClass("check").addClass("cancel");
$itemObj.children().removeClass("icon_check").addClass("icon_cancel");
restrict_rulelist_array[row_idx][0] = "0";
$trObj.css({"color" : "#A0A0A0"});
}
if($("#selAll").hasClass("all_enable"))
$("#selAll").removeClass("all_enable").addClass("all_disable");
}
function control_all_rule_status(obj) {
var set_all_rule_status = function(stauts) {
for(var i = 0; i < restrict_rulelist_array.length; i += 1) {
restrict_rulelist_array[i][0] = stauts;
}
};
var $itemObj = $(obj);
if($itemObj.hasClass("all_enable")) {
$itemObj.removeClass("all_enable").addClass("all_disable");
set_all_rule_status("1");
}
else {
$itemObj.removeClass("all_disable").addClass("all_enable");
set_all_rule_status("0");
}
show_http_clientlist();
}
function change_hddSpinDown(obj_value) {
if(obj_value == "0") {
$("#usb_idle_timeout_tr").css("display", "none");
}
else {
$("#usb_idle_timeout_tr").css("display", "");
}
}
function show_network_monitoring(){
var orig_dns_probe = httpApi.nvramGet(["dns_probe"]).dns_probe;
var orig_wandog_enable = httpApi.nvramGet(["wandog_enable"]).wandog_enable;
appendMonitorOption(document.form.dns_probe_chk);
appendMonitorOption(document.form.wandog_enable_chk);
setTimeout("showPingTargetList();", 500);
}
function appendMonitorOption(obj){
if(obj.name == "wandog_enable_chk"){
if(obj.checked){
document.getElementById("ping_tr").style.display = "";
inputCtrl(document.form.wandog_target, 1);
}
else{
document.getElementById("ping_tr").style.display = "none";
inputCtrl(document.form.wandog_target, 0);
}
}
else if(obj.name == "dns_probe_chk"){
if(obj.checked){
document.getElementById("probe_host_tr").style.display = "";
document.getElementById("probe_content_tr").style.display = "";
inputCtrl(document.form.dns_probe_host, 1);
inputCtrl(document.form.dns_probe_content, 1);
}
else{
document.getElementById("probe_host_tr").style.display = "none";
document.getElementById("probe_content_tr").style.display = "none";
inputCtrl(document.form.dns_probe_host, 0);
inputCtrl(document.form.dns_probe_content, 0);
}
}
}
var isPingListOpen = 0;
function showPingTargetList(){
var ttc = httpApi.nvramGet(["territory_code"]).territory_code;
if(ttc.search("CN") >= 0){
var APPListArray = [
["Baidu", "www.baidu.com"], ["QQ", "www.qq.com"], ["Taobao", "www.taobao.com"]
];
}
else{
var APPListArray = [
["Google ", "www.google.com"], ["Facebook", "www.facebook.com"], ["Youtube", "www.youtube.com"], ["Yahoo", "www.yahoo.com"],
["Baidu", "www.baidu.com"], ["Wikipedia", "www.wikipedia.org"], ["Windows Live", "www.live.com"], ["QQ", "www.qq.com"],
["Amazon", "www.amazon.com"], ["Twitter", "www.twitter.com"], ["Taobao", "www.taobao.com"], ["Blogspot", "www.blogspot.com"],
["Linkedin", "www.linkedin.com"], ["Sina", "www.sina.com"], ["eBay", "www.ebay.com"], ["MSN", "msn.com"], ["Bing", "www.bing.com"],
["", "www.yandex.ru"], ["WordPress", "www.wordpress.com"], ["", "www.vk.com"]
];
}
var code = "";
for(var i = 0; i < APPListArray.length; i++){
code += '<a><div onclick="setPingTarget(\''+APPListArray[i][1]+'\');"><strong>'+APPListArray[i][0]+'</strong></div></a>';
}
code +='<!--[if lte IE 6.5]><iframe class="hackiframe2"></iframe><![endif]-->';
document.getElementById("TargetList_Block_PC").innerHTML = code;
}
function setPingTarget(ipaddr){
document.form.wandog_target.value = ipaddr;
hidePingTargetList();
}
function hidePingTargetList(){
document.getElementById("ping_pull_arrow").src = "/images/arrow-down.gif";
document.getElementById('TargetList_Block_PC').style.display='none';
isPingListOpen = 0;
}
function pullPingTargetList(obj){
if(isPingListOpen == 0){
obj.src = "/images/arrow-top.gif"
document.getElementById("TargetList_Block_PC").style.display = 'block';
document.form.wandog_target.focus();
isPingListOpen = 1;
}
else
hidePingTargetList();
}
</script>
</head>
<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_System_Content.asp">
<input type="hidden" name="next_page" value="Advanced_System_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_wait" value="5">
<input type="hidden" name="action_script" value="restart_time;restart_upnp">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="time_zone_dst" value="<% nvram_get("time_zone_dst"); %>">
<input type="hidden" name="time_zone" value="<% nvram_get("time_zone"); %>">
<input type="hidden" name="time_zone_dstoff" value="<% nvram_get("time_zone_dstoff"); %>">
<input type="hidden" name="http_passwd" value="" disabled>
<input type="hidden" name="http_client" value="<% nvram_get("http_client"); %>"><input type="hidden" name="http_clientlist" value="<% nvram_get("http_clientlist"); %>"><input type="hidden" name="enable_acc_restriction" value="<% nvram_get("enable_acc_restriction"); %>">
<input type="hidden" name="restrict_rulelist" value="<% nvram_get("restrict_rulelist"); %>">
<input type="hidden" name="btn_ez_mode" value="<% nvram_get("btn_ez_mode"); %>">
<input type="hidden" name="reboot_schedule" value="<% nvram_get("reboot_schedule"); %>" disabled>
<input type="hidden" name="reboot_schedule_enable" value="<% nvram_get("reboot_schedule_enable"); %>">
<input type="hidden" name="shell_timeout" value="<% nvram_get("shell_timeout"); %>">
<input type="hidden" name="http_lanport" value="<% nvram_get("http_lanport"); %>">
<input type="hidden" name="dns_probe" value="<% nvram_get("dns_probe"); %>">
<input type="hidden" name="wandog_enable" value="<% nvram_get("wandog_enable"); %>">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div>
</td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">
<tbody>
<tr>
<td bgcolor="#4D595D" valign="top">
<div>&nbsp;</div>
<div class="formfonttitle"><#303#> - <#306#></div>
<div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
<div class="formfontdesc"><#2579#></div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><#2244#></td>
</tr>
</thead>
<tr>
<th width="40%"><#602#></th>
<td>
<div><input type="text" id="http_username" name="http_username" tabindex="1" autocomplete="off" style="height:25px;" class="input_18_table" maxlength="20" autocorrect="off" autocapitalize="off"><br/><span id="alert_msg1" style="color:#FC0;margin-left:8px;display:inline-block;"></span></div>
</td>
</tr>
<tr>
<th width="40%"><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,4)"><#360#></a></th>
<td>
<input type="password" autocomplete="off" name="http_passwd2" tabindex="2" onKeyPress="return validator.isString(this, event);" onkeyup="chkPass(this.value, 'http_passwd');" onpaste="setTimeout('paste_password();', 10)" class="input_18_table" maxlength="16" onBlur="clean_scorebar(this);" autocorrect="off" autocapitalize="off"/>
&nbsp;&nbsp;
<div id="scorebarBorder" style="margin-left:180px; margin-top:-25px; display:none;" title="<#253#>">
<div id="score"></div>
<div id="scorebar">&nbsp;</div>
</div>
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,4)"><#361#></a></th>
<td>
<input type="password" autocomplete="off" name="v_password2" tabindex="3" onKeyPress="return validator.isString(this, event);" onpaste="setTimeout('paste_password();', 10)" class="input_18_table" maxlength="16" autocorrect="off" autocapitalize="off"/>
<div style="margin:-25px 0px 5px 175px;"><input type="checkbox" name="show_pass_1" onclick="pass_checked(document.form.http_passwd2);pass_checked(document.form.v_password2);"><#506#></div>
<span id="alert_msg2" style="color:#FC0;margin-left:8px;display:inline-block;"></span>
</td>
</tr>
</table>
<table id="hdd_spindown_table" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top:8px;display:none;">
<thead>
<tr>
<td colspan="2"><#2782#></td>
</tr>
</thead>
<tr>
<th width="40%"><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,11)"><#2773#></a></th>
<td>
<select name="usb_idle_enable" class="input_option" onchange="change_hddSpinDown(this.value);" disabled>
<option value="0" <% nvram_match("usb_idle_enable", "0", "selected"); %>><#139#></option>
<option value="1" <% nvram_match("usb_idle_enable", "1", "selected"); %>><#140#></option>
</select>
</td>
</tr>
<tr id="usb_idle_timeout_tr">
<th width="40%"><#2600#></th>
<td>
<input type="text" class="input_6_table" maxlength="4" name="usb_idle_timeout" onKeyPress="return validator.isNumber(this,event);" value='<% nvram_get("usb_idle_timeout"); %>' autocorrect="off" autocapitalize="off" disabled><#2425#>
<span>(<#2452#> : 60) </span>
</td>
</tr>
<tr id="reduce_usb3_tr" style="display:none">
<th width="40%"><a class="hintstyle" href="javascript:void(0);" onclick="openHint(3, 29)">USB Mode</a></th>
<td>
<select class="input_option" name="usb_usb3" onchange="enableUsbMode(this.value);">
<option value="0" <% nvram_match("usb_usb3", "0", "selected"); %>>USB 2.0</option>
<option value="1" <% nvram_match("usb_usb3", "1", "selected"); %>>USB 3.0</option>
</select>
<script>
var needReboot = false;
if( based_modelid == "DSL-AC68U" || based_modelid == "RT-AC3200" || based_modelid == "RT-AC87U" || based_modelid == "RT-AC68U" || based_modelid == "RT-AC68A" || based_modelid == "RT-AC56S" || based_modelid == "RT-AC56U" || based_modelid == "RT-AC55U" || based_modelid == "RT-AC55UHP" || based_modelid == "RT-N18U" || based_modelid == "RT-AC88U" || based_modelid == "RT-AC86U" || based_modelid == "AC2900" || based_modelid == "RT-AC3100" || based_modelid == "RT-AC5300" || based_modelid == "RP-AC68U" || based_modelid == "RT-AC58U" || based_modelid == "RT-AC82U" || based_modelid == "MAP-AC3000" || based_modelid == "RT-AC85U" || based_modelid == "RT-AC65U" || based_modelid == "4G-AC68U" || based_modelid == "BLUECAVE" || based_modelid == "RT-AC88Q" || based_modelid == "RT-AD7200" || based_modelid == "RT-N65U" || based_modelid == "GT-AC5300" || based_modelid == "RT-AX88U" || based_modelid == "RT-AX95U" || based_modelid == "BRT-AC828"
){
$("#reduce_usb3_tr").show();
}
function enableUsbMode(v){
httpApi.nvramGetAsync({
data: ["usb_usb3"],
success: function(nvram){
needReboot = (nvram.usb_usb3 != v);
}
})
}
</script>
</td>
</tr>
</table>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top:8px;">
<thead>
<tr>
<td colspan="2"><#2580#></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,2)"><#1996#></a></th>
<td>
<select name="time_zone_select" class="input_option" onchange="select_time_zone();"></select>
<div>
<span id="timezone_hint" style="display:none;"></span>
</div>
</td>
</tr>
<tr id="dst_changes_start" style="display:none;">
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,7)"><#1997#></a></th>
<td>
<div id="dst_start" style="color:white;display:none;">
<div>
<select name="dst_start_m" class="input_option"></select>&nbsp;<#2145#> &nbsp;
<select name="dst_start_w" class="input_option"></select>&nbsp;
<select name="dst_start_d" class="input_option"></select>&nbsp;<#1379#> & <#1312#> &nbsp;
<select name="dst_start_h" class="input_option"></select>&nbsp;<#1772#> &nbsp;
<script>
for(var i = 1; i < dst_month.length; i++){
add_option(document.form.dst_start_m, dst_month[i], i, 0);
}
for(var i = 1; i < dst_week.length; i++){
add_option(document.form.dst_start_w, dst_week[i], i, 0);
}
for(var i = 0; i < dst_day.length; i++){
add_option(document.form.dst_start_d, dst_day[i], i, 0);
}
for(var i = 0; i < dst_hour.length; i++){
add_option(document.form.dst_start_h, dst_hour[i], i, 0);
}
</script>
</div>
</div>
</td>
</tr>
<tr id="dst_changes_end" style="display:none;">
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,8)"><#1999#></a></th>
<td>
<div id="dst_end" style="color:white;display:none;">
<div>
<select name="dst_end_m" class="input_option"></select>&nbsp;<#2145#> &nbsp;
<select name="dst_end_w" class="input_option"></select>&nbsp;
<select name="dst_end_d" class="input_option"></select>&nbsp;<#1379#> & <#1312#> &nbsp;
<select name="dst_end_h" class="input_option"></select>&nbsp;<#1772#> &nbsp;
<script>
for(var i = 1; i < dst_month.length; i++){
add_option(document.form.dst_end_m, dst_month[i], i, 0);
}
for(var i = 1; i < dst_week.length; i++){
add_option(document.form.dst_end_w, dst_week[i], i, 0);
}
for(var i = 0; i < dst_day.length; i++){
add_option(document.form.dst_end_d, dst_day[i], i, 0);
}
for(var i = 0; i < dst_hour.length; i++){
add_option(document.form.dst_end_h, dst_hour[i], i, 0);
}
</script>
</div>
</div>
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,3)"><#1990#></a></th>
<td>
<input type="text" maxlength="256" class="input_32_table" name="ntp_server0" value="<% nvram_get("ntp_server0"); %>" onKeyPress="return validator.isString(this, event);" autocorrect="off" autocapitalize="off">
<a href="javascript:openLink('x_NTPServer1')" name="x_NTPServer1_link" style=" margin-left:5px; text-decoration: underline;"><#1991#></a>
<div id="svc_hint_div" style="display:none;">
<span style="color:#FFCC00;"><#197#></span>
<a id="ntp_faq" href="" target="_blank" style="margin-left:5px; color: #FFCC00; text-decoration: underline;">FAQ</a>
</div>
</td>
</tr>
<tr id="network_monitor_tr">
<th><#2177#></th>
<td>
<input type="checkbox" name="dns_probe_chk" value="" <% nvram_match("dns_probe", "1", "checked"); %> onClick="appendMonitorOption(this);"><div style="display: inline-block; vertical-align: middle; margin-bottom: 2px;" ><#1402#></div>
<input type="checkbox" name="wandog_enable_chk" value="" <% nvram_match("wandog_enable", "1", "checked"); %> onClick="appendMonitorOption(this);"><div style="display: inline-block; vertical-align: middle; margin-bottom: 2px;"><#2256#></div>
</td>
</tr>
<tr id="probe_host_tr" style="display: none;">
<th><#2364#></th>
<td>
<input type="text" class="input_32_table" name="dns_probe_host" maxlength="255" autocorrect="off" autocapitalize="off" value="<% nvram_get("dns_probe_host"); %>">
</td>
</tr>
<tr id="probe_content_tr" style="display: none;">
<th><#2365#></th>
<td>
<input type="text" class="input_32_table" name="dns_probe_content" maxlength="1024" autocorrect="off" autocapitalize="off" value="<% nvram_get("dns_probe_content"); %>">
</td>
</tr>
<tr id="ping_tr" style="display: none;">
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(26,2);"><#2257#></a></th>
<td>
<input type="text" class="input_32_table" name="wandog_target" maxlength="100" value="<% nvram_get("wandog_target"); %>" placeholder="ex: www.google.com" autocorrect="off" autocapitalize="off">
<img id="ping_pull_arrow" class="pull_arrow" height="14px;" src="/images/arrow-down.gif" style="position:absolute;*margin-left:-3px;*margin-top:1px;" onclick="pullPingTargetList(this);" title="<#2434#>">
<div id="TargetList_Block_PC" name="TargetList_Block_PC" class="clientlist_dropdown" style="margin-left: 2px; width: 348px;display: none;"></div>
</td>
</tr>
<tr>
<th><#627#></th>
<td>
<input type="text" class="input_3_table" maxlength="3" name="http_autologout" value='<% nvram_get("http_autologout"); %>' onKeyPress="return validator.isNumber(this,event);" autocorrect="off" autocapitalize="off"> <#2064#>
<span>(<#3221#>)</span>
</td>
</tr>
<tr id="nat_redirect_enable_tr">
<th align="right"><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,6);"><#1485#></a></th>
<td>
<input type="radio" name="nat_redirect_enable" class="input" value="1" <% nvram_match_x("","nat_redirect_enable","1", "checked"); %> ><#140#>
<input type="radio" name="nat_redirect_enable" class="input" value="0" <% nvram_match_x("","nat_redirect_enable","0", "checked"); %> ><#139#>
</td>
</tr>
<tr id="btn_ez_radiotoggle_tr">
<th><#3195#></th>
<td>
<input type="radio" name="btn_ez_radiotoggle" id="turn_WPS" class="input" style="display:none;" value="0"><label for="turn_WPS"><#3194#></label>
<input type="radio" name="btn_ez_radiotoggle" id="turn_WiFi" class="input" style="display:none;" value="1" <% nvram_match_x("", "btn_ez_radiotoggle", "1", "checked"); %>><label for="turn_WiFi" id="turn_WiFi_str"><#3196#></label>
<input type="radio" name="btn_ez_radiotoggle" id="turn_LED" class="input" style="display:none;" value="0" <% nvram_match_x("", "btn_ez_mode", "1", "checked"); %>><label for="turn_LED" id="turn_LED_str">Turn LED On/Off</label>
</td>
</tr>
<tr id="pwrsave_tr">
<th align="right">Power Save Mode</th>
<td>
<select name="pwrsave_mode" class="input_option">
<option value="0" <% nvram_match("pwrsave_mode", "0","selected"); %> >Performance</option>
<option value="1" <% nvram_match("pwrsave_mode", "1","selected"); %> >Auto</option>
<option value="2" <% nvram_match("pwrsave_mode", "2","selected"); %> >Power Save</option>
</select>
</td>
</tr>
<tr id="reboot_schedule_enable_tr">
<th><#1487#></th>
<td>
<input type="radio" value="1" name="reboot_schedule_enable_x" onClick="hide_reboot_option(1);" <% nvram_match_x("LANHostConfig","reboot_schedule_enable", "1", "checked"); %>><#140#>
<input type="radio" value="0" name="reboot_schedule_enable_x" onClick="hide_reboot_option(0);" <% nvram_match_x("LANHostConfig","reboot_schedule_enable", "0", "checked"); %>><#139#>
</td>
</tr>
<tr id="reboot_schedule_date_tr">
<th><#2358#></th>
<td>
<input type="checkbox" name="reboot_date_x_Sun" class="input" onclick="check_Timefield_checkbox();"><#1308#>
<input type="checkbox" name="reboot_date_x_Mon" class="input" onclick="check_Timefield_checkbox();"><#1306#>
<input type="checkbox" name="reboot_date_x_Tue" class="input" onclick="check_Timefield_checkbox();"><#1310#>
<input type="checkbox" name="reboot_date_x_Wed" class="input" onclick="check_Timefield_checkbox();"><#1311#>
<input type="checkbox" name="reboot_date_x_Thu" class="input" onclick="check_Timefield_checkbox();"><#1309#>
<input type="checkbox" name="reboot_date_x_Fri" class="input" onclick="check_Timefield_checkbox();"><#1305#>
<input type="checkbox" name="reboot_date_x_Sat" class="input" onclick="check_Timefield_checkbox();"><#1307#>
</td>
</tr>
<tr id="reboot_schedule_time_tr">
<th><#2359#></th>
<td>
<input type="text" maxlength="2" class="input_3_table" name="reboot_time_x_hour" onKeyPress="return validator.isNumber(this,event);" onblur="validator.timeRange(this, 0);" autocorrect="off" autocapitalize="off"> :
<input type="text" maxlength="2" class="input_3_table" name="reboot_time_x_min" onKeyPress="return validator.isNumber(this,event);" onblur="validator.timeRange(this, 1);" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr id="ncb_enable_option_tr" style="display:none">
<th><#1498#></th>
<td>
<select name="ncb_enable_option" class="input_option">
<option value="0" <% nvram_match("ncb_enable", "0", "selected"); %>><#1499#></option>
<option value="1" <% nvram_match("ncb_enable", "1", "selected"); %>><#1500#></option>
<option value="2" <% nvram_match("ncb_enable", "2", "selected"); %>><#1501#></option>
</select>
</td>
</tr>
<tr id="sw_mode_radio_tr" style="display:none">
<th><#329#></th>
<td>
<input type="radio" name="sw_mode_radio" value="1" <% nvram_match_x("","sw_mode","3", "checked"); %> ><#140#>
<input type="radio" name="sw_mode_radio" value="0" <% nvram_match_x("","sw_mode","1", "checked"); %> ><#139#>
</td>
</tr>
</table>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top:8px;">
<thead>
<tr>
<td colspan="2"><#505#></td>
</tr>
</thead>
<tr id="telnet_tr">
<th><#1490#></th>
<td>
<input type="radio" name="telnetd_enable" class="input" value="1" <% nvram_match_x("LANHostConfig", "telnetd_enable", "1", "checked"); %>><#140#>
<input type="radio" name="telnetd_enable" class="input" value="0" <% nvram_match_x("LANHostConfig", "telnetd_enable", "0", "checked"); %>><#139#>
</td>
</tr>
<tr id="sshd_enable_tr">
<th width="40%"><#1489#></th>
<td>
<select name="sshd_enable" class="input_option" onchange="check_sshd_enable(this.value);">
<option value="0" <% nvram_match("sshd_enable", "0", "selected"); %>><#139#></option>
<option value="1" <% nvram_match("sshd_enable", "1", "selected"); %>><#140#></option>
<option value="2" <% nvram_match("sshd_enable", "2", "selected"); %>>LAN only</option>
</select>
</td>
</tr>
<tr id="sshd_port_tr">
<th width="40%"><#2284#></th>
<td>
<input type="text" class="input_6_table" maxlength="5" name="sshd_port" onKeyPress="return validator.isNumber(this,event);" value='<% nvram_get("sshd_port"); %>' autocorrect="off" autocapitalize="off">
</td>
</tr>
<!--tr id="remote_access_tr" style="display:none">
<th>Remote Access</th>
<td>
<input type="radio" name="sshd_remote" class="input" value="1" onclick="sshd_remote_access(this.value);" <% nvram_match("sshd_remote", "1", "checked"); %>><#140#>
<input type="radio" name="sshd_remote" class="input" value="0" onclick="sshd_remote_access(this.value);" <% nvram_match("sshd_remote", "0", "checked"); %>><#139#>
</td>
</tr-->
<!--tr id="remote_forwarding_tr" style="display:none">
<th>Remote Forwarding</th>
<td>
<input type="radio" name="sshd_forwarding" class="input" value="1" onclick="sshd_forward(this.value);" <% nvram_match("sshd_forwarding", "1", "checked"); %>><#140#>
<input type="radio" name="sshd_forwarding" class="input" value="0" onclick="sshd_forward(this.value);" <% nvram_match("sshd_forwarding", "0", "checked"); %>><#139#>
</td>
</tr-->
<tr id="sshd_password_tr">
<th><#1092#></th>
<td>
<input type="radio" name="sshd_pass" class="input" value="1" <% nvram_match("sshd_pass", "1", "checked"); %>><#140#>
<input type="radio" name="sshd_pass" class="input" value="0" <% nvram_match("sshd_pass", "0", "checked"); %>><#139#>
</td>
</tr>
<tr id="auth_keys_tr">
<th><#1116#></th>
<td>
<textarea rows="5" class="textarea_ssh_table" style="width:98%; overflow:auto; word-break:break-all;" name="sshd_authkeys" maxlength="2999"><% nvram_get("sshd_authkeys"); %></textarea>
</td>
</tr>
<tr>
<th width="40%"><#3303#></th>
<td>
<input type="text" class="input_3_table" maxlength="3" name="shell_timeout_x" value="" onKeyPress="return validator.isNumber(this,event);" autocorrect="off" autocapitalize="off"> <#2064#>
<span>(<#3221#>)</span>
</td>
</tr>
</table>
<table id ="http_auth_table" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top:8px;">
<thead>
<tr>
<td colspan="2"><#2023#></td>
</tr>
</thead>
<tr id="https_tr">
<th><#3019#></th>
<td>
<select name="http_enable" class="input_option" onchange="hide_https_lanport(this.value);check_wan_access(this.value);">
<option value="0" <% nvram_match("http_enable", "0", "selected"); %>>HTTP</option>
<option value="1" <% nvram_match("http_enable", "1", "selected"); %>>HTTPS</option>
<option value="2" <% nvram_match("http_enable", "2", "selected"); %>>BOTH</option>
</select>
</td>
</tr>
<tr id="https_lanport">
<th>HTTPS LAN port</th>
<td>
<input type="text" maxlength="5" class="input_6_table" name="https_lanport" value="<% nvram_get("https_lanport"); %>" onKeyPress="return validator.isNumber(this,event);" onBlur="change_url(this.value, 'https_lan');" autocorrect="off" autocapitalize="off">
<span id="https_access_page"></span>
</td>
</tr>
</table>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="margin-top:8px;">
<thead>
<tr>
<td colspan="2"><#2363#></td>
</tr>
</thead>
<tr id="misc_http_x_tr">
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(8,2);"><#1652#></a></th>
<td>
<input type="radio" value="1" name="misc_http_x" class="input" onClick="hideport(1);enable_wan_access(1);" <% nvram_match("misc_http_x", "1", "checked"); %>><#140#>
<input type="radio" value="0" name="misc_http_x" class="input" onClick="hideport(0);enable_wan_access(0);" <% nvram_match("misc_http_x", "0", "checked"); %>><#139#><br>
<span class="formfontdesc" id="WAN_access_hint" style="color:#FFCC00; display:none;"><#1653#>
<a id="faq" href="" target="_blank" style="margin-left: 5px; color:#FFCC00; text-decoration: underline;">FAQ</a>
</span>
<div class="formfontdesc" id="NSlookup_help_for_WAN_access" style="color:#FFCC00; display:none;"><#2213#></div>
</td>
</tr>
<tr id="accessfromwan_port">
<th align="right"><a id="access_port_title" class="hintstyle" href="javascript:void(0);" onClick="openHint(8,3);">HTTPS <#1655#></a></th>
<td>
<span style="margin-left:5px; display:none;" id="http_port"><input type="text" maxlength="5" name="misc_httpport_x" class="input_6_table" value="<% nvram_get("misc_httpport_x"); %>" onKeyPress="return validator.isNumber(this,event);" autocorrect="off" autocapitalize="off"/>&nbsp;&nbsp;</span>
<span style="margin-left:5px; display:none;" id="https_port"><input type="text" maxlength="5" name="misc_httpsport_x" class="input_6_table" value="<% nvram_get("misc_httpsport_x"); %>" onKeyPress="return validator.isNumber(this,event);" onBlur="change_url(this.value, 'https_wan');" autocorrect="off" autocapitalize="off"/></span>
<span id="wan_access_url"></span>
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,10);"><#631#></a></th>
<td>
<input type="radio" name="http_client_radio" value="1" onclick="display_spec_IP(1);" <% nvram_match_x("", "http_client", "1", "checked"); %>><#140#>
<input type="radio" name="http_client_radio" value="0" onclick="display_spec_IP(0);" <% nvram_match_x("", "http_client", "0", "checked"); %>><#139#>
</td>
</tr>
</table>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable_table" id="http_client_table">
<thead>
<tr>
<td colspan="4"><#632#>&nbsp;(<#2021#>&nbsp;4)</td>
</tr>
</thead>
<tr>
<th width="10%"><div id="selAll" class="all_disable" style="margin: auto;width:40px;" onclick="control_all_rule_status(this);"><#1090#></div></th>
<th width="40%"><a class="hintstyle" href="javascript:void(0);" onClick="openHint(11,9);"><#1620#></a></th>
<th width="40%"><#742#></th>
<th width="10%"><#2020#></th>
</tr>
<tr>
<td width="10%">-</td>
<td width="40%">
<input type="text" class="input_25_table" maxlength="18" name="http_client_ip_x_0" onKeyPress="" onClick="hideClients_Block();" autocorrect="off" autocapitalize="off">
<img id="pull_arrow" height="14px;" src="/images/arrow-down.gif" style="position:absolute;*margin-left:-3px;*margin-top:1px;" onclick="pullLANIPList(this);" title="<#2430#>">
<div id="ClientList_Block_PC" class="clientlist_dropdown" style="margin-left:27px;width:235px;"></div>
</td>
<td width="40%">
<input type="checkbox" name="access_webui" class="input access_type" value="1">Web UI<input type="checkbox" name="access_ssh" class="input access_type" value="2">SSH<input type="checkbox" name="access_telnet" class="input access_type" value="4">Telnet(LAN only)</td>
<td width="10%">
<div id="add_delete" class="add_enable" style="margin:0 auto" onclick="addRow(document.form.http_client_ip_x_0, 4);"></div>
</td>
</tr>
</table>
<div id="http_clientlist_Block"></div>
<div class="apply_gen">
<input name="button" type="button" class="button_gen" onclick="applyRule();" value="<#148#>"/>
</div>
</td>
</tr>
</tbody>
</table></td>
</form>
</tr>
</table>
</td>
<td width="10" align="center" valign="top">&nbsp;</td>
</tr>
</table>
<div id="footer"></div>
</body>
</html>

