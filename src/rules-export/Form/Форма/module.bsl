﻿#Область ОбработчикиСобытийФормы

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	Аргументы = СтрРазделить(ПараметрЗапуска, ";", Ложь);
	Если Аргументы.Количество() > 0 Тогда
		Для Каждого Аргумент Из Аргументы Цикл
			Если СтрНайти(ВРег(Аргумент), ВРег("acc.rulesExportPath=")) Тогда
				ПоложениеСимволаРавно = СтрНайти(Аргумент, "=");
				ЗначениеАргумента = Сред(Аргумент, ПоложениеСимволаРавно + 1, СтрДлина(Аргумент) - ПоложениеСимволаРавно);
				ЗначениеАргумента = СтрЗаменить(ЗначениеАргумента, """", "");
				
				Файл = Новый Файл(ЗначениеАргумента);
				Если Файл.Расширение = ".json" Тогда
					ЗапускИзПакетногоРежима = Истина;
					ПутьКФайлуВыгрузки = Файл.ПолноеИмя;
				КонецЕсли;
				
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриОткрытии()
	
	Если ЗапускИзПакетногоРежима Тогда
		
		// основной процесс
		ВыгрузитьПравилаПроверкиКода();
		
		// завершим сеанс
		ЗавершитьРаботуСистемы(Ложь, Ложь);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

Процедура ПутьКФайлуВыгрузкиНачалоВыбора(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	Диалог.Фильтр = "Файл выгрузки правил дианостики (*.json)|*.json";
	Диалог.Заголовок = "";
	Если Диалог.Выбрать() Тогда
		ПутьКФайлуВыгрузки = Диалог.ПолноеИмяФайла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

Процедура КнопкаВыполнитьНажатие(Кнопка)
	
	Если ПустаяСтрока(ПутьКФайлуВыгрузки) Тогда
		Предупреждение("Путь к файлу выгрузки не заполнен");
		Возврат;
	КонецЕсли;
	ВыгрузитьПравилаПроверкиКода();
	
КонецПроцедуры

#КонецОбласти