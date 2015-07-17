<?
require_once('../php/iwf.php');
$iwf->popup($iwfTarget);
$iwf->startHtml($iwfTarget);
$iwf->pretty(true);

echo "<h1>GET</h1>";

foreach($_GET as $key => $val){
	echo "'$key' = '$val'<br />";
}

echo "<h1>POST</h1>";
foreach($_POST as $key => $val){
	echo "'$key' = '$val'<br />";
}

echo "<h1>RAW POST</h1>";
echo $GLOBALS['HTTP_RAW_POST_DATA'] . "<br />";

$iwf->endHtml(true);


?>