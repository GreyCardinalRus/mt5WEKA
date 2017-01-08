<?php
$path="mt4arbitr"; // путь на серваке

$server=$_GET['server'];
$pair=$_GET['pair'];
$bid=$_GET['bid'];
$time=$_GET['time'];

$fullpath=dirname(__FILE__)."/$path/$pair"; // полный путь к папке эксперта
if ($pair!="") if (!is_dir($fullpath)) mkdir($fullpath, 0777); // если нет каталога, то создаём

$sec=20; $dt=time()-$sec; // задержка и текущее время
mt_srand($dt); $name=md5(md5($dt).rand()); // получили имя временного файла
if ($time>=$dt)  // если передаваемое время больше максимальной задержки
{
	$f=fopen($fullpath."/$server", 'wb'); // перезаписали цену
	fwrite($f, $server.";".$bid.";".$time); fflush($f); fclose($f);
}
$n=0; // счетчик файлов
print("~beg~\r\n"); // начали запись
if ($handle = opendir($fullpath))
{
	$f=fopen(dirname(__FILE__)."/$path/$name", 'wb'); // создали временный файл для вывода
	while (($file=readdir($handle))!==false)
	{
		if (is_dir($fullpath."/$file")) continue; // если папка
		if (filemtime($fullpath."/$file")<$dt) { unlink($fullpath."/$file"); continue; } // удаляем старый файл
		$s=file_get_contents($fullpath."/$file");
		fwrite($f, $s."\r\n"); $n++;
	}
	closedir($handle); 
	fflush($f); fclose($f);
} 
print($n."\r\n");
$s=file_get_contents(dirname(__FILE__)."/$path/$name"); // открыли временный файл
print($s);  // вывели на экран
unlink(dirname(__FILE__)."/$path/$name"); // удалили временные
?>