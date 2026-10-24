# Literature review and structured source analysis

**Status:** research draft for student and supervisor review, updated 24 October 2026.  
**Related issues:** [#7](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/7), [#13](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/13).

## Purpose and selection

This review supports a Flutter application for monitoring and analyzing airfare dynamics on 10–15 selected domestic directions in Kazakhstan. It asks how to obtain interpretable observations, evaluate forecasts without future information, and communicate price histories on a phone.

The selection is a targeted narrative review, not a systematic review. Searches covered airfare prediction, forecast evaluation, mobile time-series visualization, accessibility, and provider data semantics. Publisher pages, author/institutional copies, and official product documentation were checked. No reproducible search-result count or exhaustive coverage is claimed.

The corpus contains **14 distinct sources: ten scholarly publications [P1–P10] and four technical documents [D1–D4]**. The author-deposited dataset linked under P2 is supporting material, not an extra publication. Eight of the ten scholarly publications appeared in 2022–2025. Two 2019 airfare studies considered during drafting were excluded from this corpus in favor of the 2023 studies P1 and P10. P6 (2019) is retained specifically for its controlled mobile chart experiment, not as evidence about current airfares or technology. P5 (2021 issue, first published in 2019) remains a foundational taxonomy of prediction targets; its issue year does not make it a recent discovery.

Access was rechecked on 24 October 2026. P7 now uses the complete author-linked paper, including Sections 3–5. P2 combines the publisher abstract with the author's dataset description; its full methods remain unverified. The older P1 preview is no longer part of the corpus. Open full texts or author copies support P1 and P3–P10, with relevant methods and limitations inspected. This does not claim that either student has independently read, reproduced or approved every paper.

## Structured analysis: scientific publications

Reported findings below belong to the cited authors. Limitations and project applications are our critical assessment unless explicitly attributed.

| ID / evidence inspected | Approach and reported result | Limits and application to this project |
| --- | --- | --- |
| [P1](#p1) Degife and Lin, 2023. Open full article, Sections 3–5 and Table 6. | Uses 1,032,215 Ethiopian Airlines records from 2018–July 2022 and 44 decision features. GRU outperforms MLP, LSTM, ARIMA and SVR in the reported comparison; the authors also explore 7/14/30-step horizons. | Airline-provided data differ from our small, source-dependent quote history. Section 3.3 describes train/validation/test sets without reproducible date boundaries, and no open dataset is supplied. Treat GRU as an optional later candidate, with independent temporal validation and simpler baselines. |
| [P2](#p2) Bülbül, 2025. Publisher abstract plus author-deposited Mendeley dataset description, version 2. | Predicts US market-level airfares; the abstract favors Random Forest. The dataset combines DB1B and T-100 and documents 1,581,278 records with 26 columns, including Average_Fare, market share, HHI and circuity. | This is a market-level prediction problem, unlike our next daily offer observation. The dataset page verifies data structure, not the article's split, preprocessing or scores. Use features only when available at prediction time; exclude the target and later-realized information. |
| [P3](#p3) Hewamalage et al., 2023. Open article: evaluation guidance and discussion of partitioning, errors and leakage. | Tutorial-style synthesis explains how non-stationarity, data partitions and metric choices can distort forecasting comparisons. Recommends evaluation suited to the series and task. | General guidance does not establish an airfare model's accuracy. Use chronological backtesting, fit preprocessing on training data only, and compare against naïve forecasts. This does not imply that random cross-validation is invalid for every possible time-series setting. |
| [P4](#p4) Zeng et al., 2023. Conference article/author abstract and available proceedings text. | Compares one-layer LTSF-Linear models with selected Transformer forecasting models on nine real-world datasets; the reported experiments favor the linear alternatives. | Long-horizon benchmarks differ from short airfare histories. Their architecture is not identical to ordinary linear regression. Justifies strong simple baselines before complex models, not a universal claim that Transformers fail or that linear models will win here. |
| [P5](#p5) Abdella et al., 2021 issue / 2019 online. Open survey, abstract and relevant discussion. | Classifies customer-side optimal-purchase-time/minimum-price prediction separately from airline demand/revenue objectives. Reviews features and discusses external information such as social media. | The survey predates current services; proposed external features are not evidence of improvement on our data. Use it to define the target and available features. External signals remain optional rather than an unsupported requirement. |
| [P6](#p6) Brehmer et al., 2019 issue / 2018 online. Author/institutional paper copy and abstract. | Phone-based experiment with 87 crowdworkers compares linear and radial range layouts. Linear layouts enabled faster tasks; error-rate differences were limited. | Temperature ranges and controlled tasks differ from airfare histories. Begin with readable chronological plots and explicit values, then measure our users' ability to retrieve and compare prices. Does not prove every linear chart is superior. |
| [P7](#p7) Snyder et al., 2024. Full author-linked paper, Sections 3–5, pp. 2–4. | Interviews about thirteen candidate interactions informed precise inspection, single-finger support and menu-based undo/redo. | This formative qualitative study iteratively revised its prototype. It does not establish speed gains, long-term learnability or suitability for travelers. Test direct price inspection and recoverable navigation in our app. |
| [P8](#p8) Elavsky et al., 2022. Author full text and institutional publication record. | Chartability organizes accessibility checks into testable visualization heuristics. Its preliminary practitioner evaluation reports usefulness for organizing and conducting audits. | Practitioner feedback is not proof that every resulting chart is accessible. Use a text alternative, meaningful labels, non-color cues and assistive-technology checks; record actual failures and retest repairs. |
| [P9](#p9) Leffrang and Müller, 2025 issue / 2024 online. Open article, study and conclusions. | Online study with 239 participants compares point forecasts, 95% prediction intervals and ensemble plots. Interval plots supported advice use/performance in that study; confidence and perceived uncertainty affected decisions. | Context-dependent human judgment results do not validate our forecast intervals. Present a forecast as an estimate; add intervals only when statistically justified. More visually apparent uncertainty does not automatically improve decisions. |
| [P10](#p10) Aliberti et al., 2023. Complete author copy, Sections IV–VI and Tables III–IV. | Compares twelve models on 10,683 Indian fare records from 2019, using 70% for training and 30% for test/validation. Random Forest leads MAE/MAPE; Bayesian CNN leads RMSE/R² in Table III. | The paper explicitly notes non-sequential input; its Transformer uses replicated inputs to simulate sequences. The stated split does not establish a future-date holdout. This is useful model-comparison evidence, not proof of forecasting our daily price histories. |

## Details verified in the new source checks

P7's twelve participants comprised ten graduate students, one undergraduate and one software engineer, all in computer science. Approximately one-hour remote sessions tested individual interactions on scatter, bar and multi-line charts. The first author coded qualitative feedback; open-ended analysis tasks and longitudinal retention were not tested. For our Flutter chart, we therefore propose visible controls and portrait-friendly value inspection, then measure travelers' task completion and errors independently [P7, Section 4].

P2's author deposit lists Average_Fare as well as passenger counts and market descriptors. Column availability alone does not establish when a value became observable. Our feature audit must record each candidate's source and earliest availability; contemporaneous or later passenger totals cannot be assumed available to a customer before departure [P2 supporting dataset].

P1's large airline dataset and P10's tabular benchmark illustrate different conditions for model comparisons. Their rankings do not establish the best learner for a sparse Kazakhstan quote history; the relevant comparison must use our target and earlier-only inputs.

## Structured analysis: technical sources

These sources describe tools or services. They do **not** count toward the scientific-publication minimum and do not demonstrate our integration.

| ID | Verified content | Consequence and limitation |
| --- | --- | --- |
| [D1](#d1) Skyscanner Indicative Prices | Indicative results use cached searches and approximate lowest prices; the guide describes cache ages up to four days and contrasts indicative with live pricing. | A cheap-calendar result is not a guaranteed current purchasable fare. Preserve price kind and provenance; separate departure-date calendars from observation-time histories. Documentation does not prove access or domestic Kazakhstan coverage. |
| [D2](#d2) Aviasales Data API | Official guidance describes a search cache retaining data for seven days, with endpoint-specific data and API access requirements. | A successful download may contain an older observation. Store collection time separately from any supplied source time; unknown time stays unknown. Do not infer complete flight inventory, baggage or fare families from a cached minimum. No live provider calls were made for this review. |
| [D3](#d3) Flutter accessibility | Official guidance addresses semantics, screen readers, contrast, touch targets and text scaling. | Apply the checks to the actual Flutter screens, including the price chart and errors. A framework capability is not proof that this app passes an audit; native screen-reader checks remain outstanding. |
| [D4](#d4) Flutter testing | Official guidance distinguishes unit, widget and integration tests and their different scope/cost. | Keep calculation checks, interaction checks and device/integration evidence separate. The two existing Flutter checks and a Web build do not establish Android/iOS operation, backend connectivity or push delivery. |

## Synthesis and decisions

### Define what is being predicted

The distinction between customer purchase decisions, airline demand and market-level averages is central [P2, P5, P10]. Our proposed experimental target is **the next daily observed price for a fixed direction, departure date and declared comparable offer group**. If only a source-specific minimum is available, the label must say so. Such a minimum can switch between flights or tariffs; it is not automatically the price trajectory of one seat or fare class.

This target is a proposed project choice, not a result reported by those papers. A claim about cheap fare classes disappearing would require observed class-level inventory, not merely declining availability in a cached calendar.

### Collect a history that can answer the question

Fixed departure cohorts plus optional rolling horizons are our collection design choice. The scope of 10–15 directions must be agreed with the supervisor; it is not a sample-size requirement derived from the papers. Preserve route, departure date, source, offer identity when known, currency, collection time, supplied source time and cache status. Keep missingness and failures explicit [D1, D2].

A repeated cached quote may confirm continued availability of the same source record but must not be presented as a newly independent price observation. Do not manufacture a source timestamp from a flight's departure time. These are project design inferences from the source semantics.

### Evaluate before making purchase recommendations

Following the evaluation principles in P3, the baseline lesson in P4 and the model comparison in P10, compare a last-observed-price baseline, a prior-history median and a simple fitted candidate. For each evaluation origin, train only on earlier information; tune on earlier validation periods and keep the final period untouched until evaluation. A feature's value must have been available at the forecast time.

Report MAE in KZT, sample count, collection span, routes, horizons, missingness and comparison with the same baseline on the same cases. Evaluate threshold crossings separately if they become a prediction task. No paper supplies a defensible accuracy target for our dataset, and no reported foreign-market score is adopted as our expected result.

### Design for reading and acting on a phone

The mobile studies favor testing concrete retrieval and navigation tasks rather than adding decorative chart interactions [P6, P7]. Proposed tasks are: find the latest observed price, identify the departure date, compare two observations, distinguish stale/demo data, and save a threshold. Record completion, errors and time on declared devices.

Use Chartability and Flutter guidance together for labels, readable text alternatives, non-color cues, scaling and assistive-technology checks [P8, D3]. Scientific study participants are not substitutes for our own required 3–5 user discussions.

Uncertainty presentation is a separate design question from model accuracy [P9]. A descriptive median is not a forecast guarantee; a synthetic five-point demo does not justify a calibrated 95% interval or a confident “buy now” recommendation.

## Traceability to project artifacts

These are proposed changes/checks, not a claim that all requirements are implemented.

| Decision or check | Supporting sources | Requirements / planned verification |
| --- | --- | --- |
| Preserve source semantics; separate cache age, collection time and demo data | D1, D2 | FR-03/05/11/12; VT-03/05/06 |
| Keep histories for fixed departure dates; report horizon and coverage | P1, P2, P5 | FR-04/06; VT-04/07 and live-source pilot |
| Compare simple forecasts using earlier information only | P3, P4, P10 | FR-06; statistical/ML evaluation plan |
| Test value reading, navigation, no-data and error states | P6, P7, D4 | FR-02/04/09; VT-02/10 |
| Provide readable chart alternatives and audit real screens | P8, D3 | NFR-08; extend VT-10 with accessibility checks |
| Label forecast uncertainty and avoid unsupported certainty | P9 | FR-06, NFR-08; understanding assessment |

See [requirements](REQUIREMENTS.md), [verification plan](VERIFICATION_PLAN.md), [existing systems](EXISTING_SYSTEMS.md) and [technology comparison](TECHNOLOGY_COMPARISON.md). Provider coverage and source access must be established separately.

## Division of review work

This is a **proposed allocation for student review**, not a record of completed individual contributions.

| Student | Non-overlapping sources | Review deliverable |
| --- | --- | --- |
| Dinmukhammed, @Swoksaar0 | P6–P9, D3–D4: six sources, four scientific | Verify UI/accessibility findings, inspect available papers, relate them to Flutter screens and update user-test tasks. |
| Bekbauly, @Bekbauly | P1–P5, P10, D1–D2: eight sources, six scholarly | Verify prediction/data assumptions, obtain fuller methods where access was limited, define observation identity and review the temporal evaluation protocol. |

Each student should record actual reading notes, corrections and a peer review from their own account. P1/P7 full texts and P10's author copy are linked for this review. Resolve or retain P2's access limit explicitly; a dataset description does not substitute for the article's methods. Student reading and peer review remain separate work.

## Implementation boundary and remaining evidence

The current Flutter demo contains synthetic observations and device-local thresholds/favorites. It supplies no training dataset or measured forecast accuracy. The GitHub backend still has documented provenance/time/history defects; the literature does not repair them. No provider integration, native accessibility result, delivered push or user-study result follows from this document.

Before acceptance: both students review the sources and synthesis; incorporate real user and supervisor comments; confirm the final route sample and forecast target; run the documented checks after implementation. No interviews, supervisor approval or publication reproduction is claimed here.

## References

Publication year means issue/proceedings year where stated. Technical pages were consulted on 23 October 2026; the P1/P2/P7 access checks and the newer-paper selection were updated on 24 October 2026.

<a id="p1"></a>
**[P1]** Degife, W. A., and Lin, B.-S. (2023). *Deep-Learning-Powered GRU Model for Flight Ticket Fare Forecasting.* Applied Sciences, 13(10), 6032. [Publisher and DOI](https://www.mdpi.com/2076-3417/13/10/6032); [complete publisher PDF](https://mdpi-res.com/d_attachment/applsci/applsci-13-06032/article_deploy/applsci-13-06032-with-cover.pdf?version=1684704119).

<a id="p2"></a>
**[P2]** Bülbül, K. G. (2025). *Airfare prediction: Leveraging market data for better decision-making.* Research in Transportation Business & Management, 61, 101408. [Publisher](https://www.sciencedirect.com/science/article/pii/S2210539525001233); [DOI](https://doi.org/10.1016/j.rtbm.2025.101408). Supporting material: Bülbül, K. G. (2025), *Airline_Market_Fare_Prediction_Data*, version 2, [author-deposited dataset description](https://data.mendeley.com/datasets/m5mvxdx2wp/2), DOI 10.17632/m5mvxdx2wp.2.

<a id="p3"></a>
**[P3]** Hewamalage, H., Ackermann, K., and Bergmeir, C. (2023; online 2022). *Forecast evaluation for data scientists: common pitfalls and best practices.* Data Mining and Knowledge Discovery, 37, 788–832. [Open publisher article / DOI](https://link.springer.com/article/10.1007/s10618-022-00894-5).

<a id="p4"></a>
**[P4]** Zeng, A., Chen, M., Zhang, L., and Xu, Q. (2023). *Are Transformers Effective for Time Series Forecasting?* Proceedings of the AAAI Conference on Artificial Intelligence, 37(9), 11121–11128. [Proceedings article / DOI](https://ojs.aaai.org/index.php/AAAI/article/view/26317).

<a id="p5"></a>
**[P5]** Abdella, J. A., Zaki, N. M., Shuaib, K., and Khan, F. (2021; online 2019). *Airline ticket price and demand prediction: A survey.* Journal of King Saud University—Computer and Information Sciences, 33(4), 375–391. [Open publisher article / DOI](https://link.springer.com/article/10.1016/j.jksuci.2019.02.001).

<a id="p6"></a>
**[P6]** Brehmer, M., Lee, B., Isenberg, P., and Choe, E. K. (2019; online 2018). *Visualizing Ranges over Time on Mobile Phones: A Task-Based Crowdsourced Evaluation.* IEEE Transactions on Visualization and Computer Graphics, 25(1), 619–629. [Author-institution record](https://www.microsoft.com/en-us/research/publication/visualizing-ranges-over-time-on-mobile-phones-a-task-based-crowdsourced-evaluation/); [author copy](https://www.microsoft.com/en-us/research/uploads/prod/2018/07/InfoVis1069-Jul27-opt.pdf); [DOI](https://doi.org/10.1109/TVCG.2018.2865234).

<a id="p7"></a>
**[P7]** Snyder, L. S., Rossi, R. A., Koh, E., Heer, J., and Hoffswell, J. (2024). *Interaction Techniques for Exploratory Data Visualization on Mobile Devices.* EuroVis 2024 — Short Papers. [Author-institution record](https://research.adobe.com/publication/interaction-techniques-for-exploratory-data-visualization-on-mobile-devices/); [DOI](https://doi.org/10.2312/evs.20241057); [University of Washington author page](https://idl.uw.edu/papers/mobile-vis-interaction-techniques); [complete author-linked paper](https://arxiv.org/pdf/2404.11602).

<a id="p8"></a>
**[P8]** Elavsky, F., Bennett, C., and Moritz, D. (2022). *How accessible is my visualization? Evaluating visualization accessibility with Chartability.* Computer Graphics Forum, 41(3), 57–70. [Author-institution record](https://dig.cmu.edu/publications/2022-chartability.html); [author full text](https://www.frank.computer/chartability/); [DOI](https://doi.org/10.1111/cgf.14522).

<a id="p9"></a>
**[P9]** Leffrang, D., and Müller, O. (2025; online 2024). *Visualizing Uncertainty in Time Series Forecasts: The Impact of Uncertainty Visualization on Users' Confidence, Algorithmic Advice Utilization, and Forecasting Performance.* Journal of Forecasting, 44(4), 1235–1246. [Open publisher article / DOI](https://onlinelibrary.wiley.com/doi/10.1002/for.3222).

<a id="p10"></a>
**[P10]** Aliberti, A., Xin, Y., Viticchiè, A., Macii, E., and Patti, E. (2023). *Comparative analysis of neural networks techniques to forecast Airfare Prices.* 2023 IEEE 47th Annual Computers, Software, and Applications Conference (COMPSAC), 1023–1029. [DOI](https://doi.org/10.1109/COMPSAC57700.2023.00157); [university publication record](https://iris.polito.it/handle/11583/2980935); [complete author-hosted paper](https://xinyaoict.github.io/files/paper.pdf).

<a id="d1"></a>
**[D1]** Skyscanner. *Flights Indicative Prices API — Overview.* [Official documentation](https://developers.skyscanner.net/docs/flights-indicative-prices/overview).

<a id="d2"></a>
**[D2]** Travelpayouts. *Aviasales Data API.* [Official documentation](https://support.travelpayouts.com/hc/en-us/articles/203956163-Aviasales-Data-API).

<a id="d3"></a>
**[D3]** Flutter. *Accessibility.* [Official documentation](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility).

<a id="d4"></a>
**[D4]** Flutter. *Testing overview.* [Official documentation](https://docs.flutter.dev/testing/overview).

