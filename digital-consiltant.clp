;;; ============================================================
;;; Экспертная система "Digital-консультант" для ООО "АВАЙО"
;;; База знаний в формате оболочки CLIPS
;;; Предметная область: подбор типа сайта и стратегии продвижения
;;; для клиента digital-агентства Avaio Media (г. Воронеж)
;;; ============================================================

;;; ----------- Шаблоны фактов (структура рабочей памяти) -------

(deftemplate client
   (slot sphere    (allowed-values retail services b2b horeca startup))
   (slot goal      (allowed-values sales leads image info))
   (slot catalog   (allowed-values one few many))
   (slot site      (allowed-values none old modern))
   (slot devbudget (allowed-values low mid high))
   (slot adbudget  (allowed-values low mid high))
   (slot urgency   (allowed-values fast normal))
   (slot geo       (allowed-values city region country)))

(deftemplate recommendation
   (slot type)          ; site / channel / dev / branding / extra
   (slot value)
   (slot cf (type FLOAT)))

;;; ----------- Правила выбора типа сайта -----------------------

(defrule R1-shop
   (client (goal sales) (catalog many))
   =>
   (assert (recommendation (type site) (value internet-magazin) (cf 0.95)))
   (printout t "R1: цель=продажи, каталог большой -> интернет-магазин" crlf))

(defrule R3-landing
   (client (goal sales) (catalog one))
   =>
   (assert (recommendation (type site) (value landing) (cf 0.9)))
   (printout t "R3: цель=продажи, продукт один -> продающий лендинг" crlf))

(defrule R5-corporate
   (client (goal leads) (catalog few))
   =>
   (assert (recommendation (type site) (value korporativny-sait) (cf 0.85)))
   (printout t "R5: цель=лиды, несколько направлений -> корпоративный сайт" crlf))

(defrule R6-image
   (client (goal image))
   =>
   (assert (recommendation (type site) (value promo-sait) (cf 0.8)))
   (printout t "R6: цель=имидж -> корпоративный/промо-сайт" crlf))

;;; ----------- Правила о состоянии текущего сайта --------------

(defrule R9-no-site
   (client (site none))
   =>
   (assert (recommendation (type dev) (value razrabotka-s-nulya) (cf 1.0)))
   (printout t "R9: сайта нет -> разработка с нуля" crlf))

(defrule R10-redesign
   (client (site old))
   =>
   (assert (recommendation (type dev) (value redesign) (cf 0.9)))
   (printout t "R10: сайт устарел -> редизайн перед рекламой" crlf))

;;; ----------- Правила выбора канала продвижения ---------------

(defrule R14-context
   (client (urgency fast))
   =>
   (assert (recommendation (type channel) (value kontekstnaya-reklama) (cf 0.9)))
   (printout t "R14: результат нужен быстро -> контекстная реклама" crlf))

(defrule R15-seo
   (client (urgency normal) (adbudget low))
   =>
   (assert (recommendation (type channel) (value seo) (cf 0.85)))
   (printout t "R15: готовы ждать, бюджет низкий -> SEO-продвижение" crlf))

(defrule R17-complex
   (client (adbudget high))
   =>
   (assert (recommendation (type channel) (value kompleksnoe-prodvizhenie) (cf 0.85)))
   (printout t "R17: бюджет высокий -> контекст + SEO + медийная реклама" crlf))

(defrule R18-geo
   (recommendation (type channel) (value kontekstnaya-reklama))
   (client (geo city))
   =>
   (assert (recommendation (type extra) (value geotargeting) (cf 0.9)))
   (printout t "R18: контекст + один город -> геотаргетинг на город" crlf))

;;; ----------- Правила фирменного стиля ------------------------

(defrule R20-branding
   (client (sphere startup))
   =>
   (assert (recommendation (type branding) (value firmenny-stil) (cf 0.85)))
   (printout t "R20: стартап -> разработка логотипа и фирменного стиля" crlf))

;;; ----------- Тестовый пример ---------------------------------
;;; Клиент: розничный магазин, цель - онлайн-продажи, большой
;;; каталог, сайта нет, результат нужен быстро, город Воронеж.

(deffacts test-client
   (client (sphere retail) (goal sales) (catalog many)
           (site none) (devbudget mid) (adbudget mid)
           (urgency fast) (geo city)))

;;; Запуск: (reset) (run) (facts)
