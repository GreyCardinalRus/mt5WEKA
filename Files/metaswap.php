<?php

if ($_SERVER['REQUEST_METHOD']=='POST')
{
	$m_server=$_POST['server'];
	$m_pair=$_POST['pair'];
	$m_long=$_POST['long'];
	$m_short=$_POST['short'];
}
else if ($_SERVER['REQUEST_METHOD']=='GET')
{
	$m_server=$_GET['server'];
	$m_pair=$_GET['pair'];
	$m_long=$_GET['long'];
	$m_short=$_GET['short'];
}

$m_path=dirname(__FILE__)."/$m_pair"; // полный путь к папке
if ($m_pair!="") if (!is_dir($m_path)) mkdir($m_path, 0766); // если нет каталога, то создаём

$f=fopen($m_path."/$m_server", 'wb'); // перезаписали своп
fwrite($f, $m_server.";".$m_long.";".$m_short); fflush($f); fclose($f);

$n=0; $out=""; // счетчик файлов
$dir=opendir($m_path);
if ($dir)
{
	while (($file=readdir($dir))!==false)
	{
		if (is_dir("$file")) continue; // если папка, то пропускаем
		$out.=file_get_contents("$m_path/$file")."\r\n"; // добавили содержимое 
		$n++; // увеличили счетчик
	}
	closedir($dir); 
} 
print("~beg~\r\n".$n."\r\n".$out."~end~\r\n");  // вывели на экран
?>