<?php
$path="mt4arbitr"; // ���� �� �������

$server=$_GET['server'];
$pair=$_GET['pair'];
$bid=$_GET['bid'];
$time=$_GET['time'];

$fullpath=dirname(__FILE__)."/$path/$pair"; // ������ ���� � ����� ��������
if ($pair!="") if (!is_dir($fullpath)) mkdir($fullpath, 0777); // ���� ��� ��������, �� ������

$sec=20; $dt=time()-$sec; // �������� � ������� �����
mt_srand($dt); $name=md5(md5($dt).rand()); // �������� ��� ���������� �����
if ($time>=$dt)  // ���� ������������ ����� ������ ������������ ��������
{
	$f=fopen($fullpath."/$server", 'wb'); // ������������ ����
	fwrite($f, $server.";".$bid.";".$time); fflush($f); fclose($f);
}
$n=0; // ������� ������
print("~beg~\r\n"); // ������ ������
if ($handle = opendir($fullpath))
{
	$f=fopen(dirname(__FILE__)."/$path/$name", 'wb'); // ������� ��������� ���� ��� ������
	while (($file=readdir($handle))!==false)
	{
		if (is_dir($fullpath."/$file")) continue; // ���� �����
		if (filemtime($fullpath."/$file")<$dt) { unlink($fullpath."/$file"); continue; } // ������� ������ ����
		$s=file_get_contents($fullpath."/$file");
		fwrite($f, $s."\r\n"); $n++;
	}
	closedir($handle); 
	fflush($f); fclose($f);
} 
print($n."\r\n");
$s=file_get_contents(dirname(__FILE__)."/$path/$name"); // ������� ��������� ����
print($s);  // ������ �� �����
unlink(dirname(__FILE__)."/$path/$name"); // ������� ���������
?>