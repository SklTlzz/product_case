# Анализ e-commerce датасета

**[Датасет на Kaggle](https://www.kaggle.com/datasets/daichiuchigashima/thelook-ecommerce?resource=download&select=thelook_ecommerce.order_items.csv)**

Анализ e-commerce датасета TheLook. Все вычисления была проведены на чистом SQL и визуализированы с помощью Power BI

## Ключевые находки
- **RFM** - Выявил, что людей из сегмента VIP всего около 4,2%, но их ARPU $303, что примерно в 3.7 раза больше, чем общий ARPU
- **Воронка конверсий** - Обнаружил, что воронка затрагивает преимущественно переходы сразу на карточку товара - трафик в основном целевой/поисковый
- **Возвраты и отмены** - Доля возвратов и отмен составляет примерно 25,05% от всех заказов

## Стек технологий 
- **Python + SQLAlchemy + Pandas** - Загрузка данных в БД
- **PostgreSQL** - Основная логика, расчет метрик
- **Power BI** - Визуализация основных результатов
- **DAX** - Написание базовых мер в Power BI

## Дашборд
<img width="1340" height="771" alt="image" src="https://github.com/user-attachments/assets/3bbe6107-0e6a-44f7-bda9-ecf9cad46c08" />
<img width="1344" height="775" alt="image" src="https://github.com/user-attachments/assets/f2287948-a33c-46d5-bfe8-c22e0cda400b" />
<img width="1340" height="774" alt="image" src="https://github.com/user-attachments/assets/e3a461a6-3c9f-43da-9806-afb0080f6386" />

## Ключевой функционал
- **Автоматическая загрузка данных в БД** - Скрипт на Python подгружает данные, разбивает их на куски и загружает в БД
- **Визуализация** - Дашборд в Power BI показывает основные метрики для анализа бизнеса
- **RFM-анализ** - Полностью написана логика RFM-сегментации пользователей
- **SQL** - Все вычисления написаны на SQL с использованием сложный конструкций (оконные функции, CTE)
