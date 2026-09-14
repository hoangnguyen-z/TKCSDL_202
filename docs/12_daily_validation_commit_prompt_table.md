# Daily Testing & Validation Commit Prompt Table

**Thời gian:** 14/09/2026 - 19/09/2026  
**Tần suất:** 5 commit độc lập mỗi ngày, 30 commit tổng cộng  
**Vai trò:** T-SQL Testing & Validation Lead

## Quy tắc bắt buộc

- Mỗi dòng là một prompt và một commit riêng; không gộp nhiều dòng vào cùng commit.
- Chỉ stage file thuộc dòng đang thực hiện; kiểm tra `git diff` trước khi commit.
- Không sửa hoặc reset phần việc của thành viên khác; không force-push.
- Test mới phải có mã `TST-*`, setup/cleanup, assertion và liên kết RTM.
- Chạy test liên quan trước commit; nếu SQL Server/Docker chưa sẵn sàng, ghi `BLOCKED` kèm bằng chứng.
- Không stage `.env`, secret, binary sinh ra, `book.pdf` hoặc file tạm ngoài phạm vi.

## Bảng prompt theo ngày

| Ngày | Commit riêng | Phạm vi đa dạng | Prompt thực hiện | Kiểm chứng bắt buộc |
| --- | --- | --- | --- | --- |
| 14/09 | `docs(validation): inventory SQL baseline` | Baseline | Kiểm kê database objects, 15 test SQL, tài liệu, Docker và các gap coverage; cập nhật baseline Validation Lead, không sửa logic. | Inventory có số lượng, đường dẫn và blocker môi trường. |
| 14/09 | `test(sql): verify runner completeness` | Test runner | Rà soát `tests/00_run_all_tests.sql`; bảo đảm gọi đúng 100% test, đúng thứ tự và có fail-fast/header rõ ràng. | Số `:r` bằng số test; không có file thiếu hoặc bị bỏ sót. |
| 14/09 | `docs(testing): publish static test checklist` | Test quality | Kiểm tra mã test, setup, assertion, expected failure, cleanup, độc lập thứ tự chạy và secret; ghi checklist và kết quả rà soát. | Mỗi test có trạng thái checklist và gap cụ thể. |
| 14/09 | `docs(rtm): reconcile requirement links` | RTM | Đối chiếu FR/NFR/BR giữa requirement baseline, RTM và test; ghi link đứt, ID sai và coverage gap, không tự tạo requirement. | ID không hợp lệ và test filename sai được liệt kê. |
| 14/09 | `test(environment): document repeatable setup` | Docker/setup | Kiểm tra `docker-compose.yml`, `.env.example`, init script và thứ tự database `00`-`09`; ghi hướng dẫn chạy lại và blocker. | Tên DB, port, biến môi trường và trạng thái Docker khớp nhau. |
| 15/09 | `test(schema): cover primary and foreign keys` | Integrity | Bổ sung test dương/âm cho FK của registration, submission, verification, judging, result và archive. | Lỗi bị chặn đúng constraint; không có orphan row sau cleanup. |
| 15/09 | `test(schema): cover unique business keys` | Uniqueness | Kiểm thử registration, frame trong roll, submission trong contest và evaluation trong round; kiểm tra trường hợp khác contest/round vẫn hợp lệ. | Expected duplicate failure và valid cross-scope case đều pass. |
| 15/09 | `test(schema): cover check boundaries` | Boundary data | Kiểm thử status, score, weight, rank và date ở min/max/null/out-of-range theo `02_constraints.sql`. | Mỗi boundary có expected result, không chỉ kiểm tra script chạy. |
| 15/09 | `test(seed): validate reference idempotency` | Reference seed | Kiểm tra seed reference có mã duy nhất, đủ dữ liệu cho test và chạy lại an toàn theo thiết kế. | Không phát sinh duplicate reference hoặc FK failure. |
| 15/09 | `test(seed): validate demo data graph` | Demo seed | Quét seed demo theo CRUD/ownership matrix; xác nhận liên kết, trạng thái và business key trước khi dùng cho test. | Consistency queries trả zero violation. |
| 16/09 | `test(submission): cover creation procedure` | Procedure | Kiểm thử submission hợp lệ, owner sai, frame trùng contest, frame khác contest, quá hạn và status sai cho `usp_create_submission`. | Procedure rollback đầy đủ khi input thất bại. |
| 16/09 | `test(verification): cover human decision gate` | Workflow | Kiểm thử AI flag advisory, human review bắt buộc, terminal status và submission không tồn tại cho verification procedure. | AI không tự chuyển verification sang trạng thái cuối. |
| 16/09 | `test(result): cover finalization procedure` | Workflow | Kiểm thử thiếu evaluation, score thiếu, finalize thành công, gọi lại và thay đổi sau finalize cho `usp_finalize_results_for_round`. | Kết quả idempotent hoặc lỗi rõ ràng đúng thiết kế. |
| 16/09 | `test(sql): cover functions with boundary inputs` | Functions | Kiểm kê functions và test normal/null/boundary/not-found/multi-row result bằng expected set. | Kết quả được so sánh với expected data, không chỉ smoke-run. |
| 16/09 | `test(sql): verify transaction rollback` | Transactions | Gây lỗi ở bước cuối của procedure nhiều bảng; xác minh rollback, `XACT_STATE()`, `@@TRANCOUNT` và không có partial rows. | Database sạch sau cả success và failure path. |
| 17/09 | `test(reporting): validate view semantics` | Reporting | Đối chiếu các reporting view với truy vấn nguồn; kiểm tra duplicate join, missing relation và status filter trên seed data. | Row count và expected columns/values khớp. |
| 17/09 | `test(audit): validate lifecycle history` | Audit | Kiểm thử audit insert/update status, old/new value, actor/context và update không đổi giá trị cho các aggregate chính. | Audit event đúng số lượng và nội dung. |
| 17/09 | `test(sql): validate set based triggers` | Triggers | Kiểm thử multi-row insert/update, nested side effect và lỗi giữa batch; không giả định trigger chỉ xử lý một row. | Batch result đúng, không tạo side effect ngoài ý muốn. |
| 17/09 | `test(archive): validate snapshot immutability` | Archive | Xác minh archive chỉ lấy từ finalized result, snapshot không đổi khi live data đổi và không tạo duplicate. | Snapshot comparison pass và delete protection còn hiệu lực. |
| 17/09 | `test(retention): cover restricted deletion matrix` | Retention | Mở rộng delete matrix cho registration, submission, evaluation, result và archive; xác minh status transition là đường thay thế. | Mỗi entity có expected `NO ACTION`/policy result. |
| 18/09 | `test(judging): isolate multi round data` | Integration | Kiểm thử round 1/round 2 với judge, criterion và evaluation khác nhau; chống trộn dữ liệu khi finalize. | Scope round/category được giữ đúng qua toàn flow. |
| 18/09 | `test(concurrency): probe duplicate protection` | Concurrency | Mô phỏng hai session cùng tạo registration/submission/evaluation; ghi isolation, lock, duplicate và deadlock behavior. | Có kết quả chạy hoặc `BLOCKED` với log môi trường. |
| 18/09 | `test(sql): cover malformed inputs` | Data quality | Kiểm thử nullability, URI/path, email, date, status và FK với dữ liệu bẩn; xác nhận lỗi ở đúng lớp. | Không lộ secret; cleanup chạy cả khi exception. |
| 18/09 | `test(sql): add consistency scans` | Data mining | Tạo truy vấn quét toàn kho tìm orphan, duplicate key, archive thiếu result, submission thiếu frame và audit thiếu aggregate. | Dữ liệu hợp lệ trả zero rows cho mọi violation query. |
| 18/09 | `test(performance): verify critical indexes` | Performance | Đối chiếu view/procedure/query với index; ghi execution plan hoặc thống kê cho scan/join bất thường, chỉ sửa index khi có bằng chứng. | Kết quả trước/sau không đổi và plan evidence được lưu. |
| 19/09 | `docs(validation): record full gate` | Release gate | Chạy initialization, seed, full runner, consistency scans và document checks; lập pass/fail/blocked log có SHA và môi trường. | Không đánh dấu pass cho test chưa chạy. |
| 19/09 | `docs(rtm): complete bidirectional traceability` | RTM | Nối hai chiều FR/NFR/BR -> test và test -> requirement; đánh dấu uncovered, duplicate và static-only coverage. | Không còn link đứt không được ghi nhận. |
| 19/09 | `docs(validation): align project artifacts` | Documentation | Đối chiếu README, architecture, physical design, assignment, RTM, scripts và runner; sửa path/tên/port/số lượng sai. | Các đường dẫn và hướng dẫn chạy lại được kiểm tra. |
| 19/09 | `docs(validation): assess regression risk` | Risk | Lập smoke/full regression checklist theo module, owner, severity, blocker và release risk; không che giấu gap. | Mỗi module có test scope và trạng thái rõ ràng. |
| 19/09 | `docs(validation): finalize lead report` | Closure | Tổng hợp coverage, pass/fail/blocked, defects, gaps, evidence, rerun guide và release decision; chỉ stage report. | Working tree ngoài phạm vi không bị đưa vào commit. |

## Quy trình commit cho từng dòng

```powershell
git status --short
git diff -- <file-thuoc-prompt>
git add -- <file-thuoc-prompt>
git diff --cached --check
git commit -m "<commit message trong bảng>"
git show --stat --oneline HEAD
git push origin main
```

Nếu một prompt cần sửa nhiều file liên quan, đó vẫn là **một commit riêng cho đúng prompt đó**; không gộp với prompt khác trong cùng ngày.