# Testing & Validation Lead: Commit Prompt Schedule

**Thời gian:** 14/09/2026 - 19/09/2026  
**Số lượng:** 5 prompt mỗi ngày, 30 prompt tổng cộng  
**Vai trò:** T-SQL Testing & Validation Lead

## Quy ước áp dụng cho mọi prompt

Mỗi prompt bên dưới được dùng như một yêu cầu độc lập cho một commit.

1. Đọc các artifact liên quan trước khi sửa: requirement, RTM, schema, procedure, view, trigger, seed và test hiện có.
2. Không sửa dữ liệu hoặc test hiện có chỉ để làm cho test pass; nếu phát hiện lỗi thiết kế, ghi nhận nguyên nhân và sửa ở lớp kiểm soát phù hợp.
3. Test âm tính phải chứng minh lỗi bị chặn đúng cách; test dương tính phải chứng minh nghiệp vụ hợp lệ vẫn hoạt động.
4. Mỗi test phải có tiền tố `TST-`, dữ liệu cô lập, cleanup rõ ràng và kết quả dễ đọc trong SSMS/sqlcmd.
5. Sau thay đổi, cập nhật `docs/07_validation_traceability.md` nếu có requirement, BR, flow hoặc test mới.
6. Chạy lại `tests/00_run_all_tests.sql` và các test liên quan; ghi kết quả vào commit message hoặc PR description.
7. Không commit secret, file `.env`, dữ liệu cá nhân thật hoặc artifact sinh ra trong thư mục tạm.
8. Trước khi commit, review `git diff` và chỉ stage file thuộc prompt hiện tại; không reset, checkout, force-push hoặc ghi đè phần việc của thành viên khác.

Mẫu commit khuyến nghị: `test(sql): <phạm vi kiểm thử ngắn gọn>` hoặc `docs(rtm): <liên kết được cập nhật>`.

## Ngày 14/09/2026 - Baseline và kiểm kê

### Prompt 01 - Kiểm kê baseline

Bạn là Testing & Validation Lead. Hãy kiểm kê toàn bộ `database/`, `tests/`, `docs/`, `README.md` và `docker/`; lập danh sách object SQL, test hiện có, requirement/BR được bao phủ và khoảng trống. Không sửa logic. Tạo hoặc cập nhật một bảng baseline trong tài liệu validation, chạy kiểm tra cú pháp/khả năng thực thi phù hợp, ghi rõ blocker môi trường. Commit: `docs(validation): establish SQL baseline inventory`.

### Prompt 02 - Chuẩn hóa test runner

Rà soát `tests/00_run_all_tests.sql` và toàn bộ file test được gọi. Bảo đảm runner gọi đúng 100% test hiện có, đúng thứ tự phụ thuộc, không trỏ tới file sai và có tiêu đề kết quả rõ ràng. Nếu cần, sửa runner tối thiểu và kiểm tra SQLCMD Mode/SSMS. Commit: `test(sql): normalize validation test runner`.

### Prompt 03 - Kiểm tra quy ước test

Tạo checklist kiểm tra tĩnh cho test T-SQL: mã test duy nhất, setup dữ liệu, assertion, xử lý lỗi mong đợi, cleanup, không phụ thuộc thứ tự chạy và không dùng secret. Áp checklist cho 15 test hiện có, sửa các vi phạm nhỏ có thể xác minh. Cập nhật RTM nếu mã test thay đổi. Commit: `test(sql): enforce test script conventions`.

### Prompt 04 - Xác minh requirement ID và RTM

Đối chiếu ID FR/NFR/BR trong `docs/02_requirement_analysis.md` với `docs/07_validation_traceability.md`, test và tài liệu assignment. Tìm ID trùng, ID không tồn tại, liên kết đứt hoặc test ghi sai mục tiêu. Sửa RTM và thêm ghi chú gap, không tự tạo requirement mới nếu chưa có nguồn. Commit: `docs(rtm): reconcile requirement and test identifiers`.

### Prompt 05 - Kiểm tra khả năng tái lập môi trường

Kiểm tra chuỗi `docker-compose.yml` -> `docker/init-database.ps1` -> các script `database/00` đến `09`. Xác minh thứ tự khởi tạo, tên database, port, biến môi trường, encoding và khả năng chạy lại. Ghi lại lỗi tái lập được và sửa phần cấu hình/documentation thuộc phạm vi validation. Commit: `test(environment): verify repeatable SQL Server setup`.

## Ngày 15/09/2026 - Schema, constraints và reference data

### Prompt 06 - Kiểm thử khóa chính và khóa ngoại

Đọc `database/01_tables.sql` và `02_constraints.sql`. Bổ sung test âm tính cho từng nhóm foreign key quan trọng: registration, submission, verification, judging, result và archive; đồng thời có test dương tính cho liên kết hợp lệ. Assertion phải xác nhận lỗi đúng constraint hoặc trạng thái thất bại. Cập nhật RTM cho các rule liên quan. Commit: `test(sql): cover core primary and foreign keys`.

### Prompt 07 - Kiểm thử unique và alternate key

Rà soát toàn bộ unique constraint/index trong schema. Bổ sung hoặc củng cố test cho registration duy nhất, frame number trong roll, submission theo contest/frame và evaluation theo judge/submission/round. Kiểm tra cả bản ghi hợp lệ ở contest/round khác. Commit: `test(sql): cover uniqueness business rules`.

### Prompt 08 - Kiểm thử CHECK constraint

Liệt kê mọi CHECK constraint cho status, score, weight, date và enum-like code. Với mỗi nhóm, tạo boundary tests gồm giá trị nhỏ nhất, lớn nhất, null nếu bị cấm và giá trị ngoài miền. Kết quả phải phân biệt constraint failure với procedure validation. Commit: `test(sql): cover check constraint boundaries`.

### Prompt 09 - Kiểm tra seed reference data

Rà soát `database/08_seed_reference_data.sql` và các foreign key sử dụng reference data. Viết kiểm tra idempotency hoặc điều kiện chạy lại an toàn, kiểm tra mã reference duy nhất và phát hiện seed thiếu giá trị mà test cần. Không dùng `MERGE` hoặc thay đổi chiến lược nếu chưa có lý do. Commit: `test(seed): validate reference data integrity`.

### Prompt 10 - Kiểm tra seed demo data

Rà soát `database/09_seed_demo_data.sql` theo CRUD/ownership matrix. Bổ sung kiểm tra số lượng tối thiểu, liên kết hợp lệ, trạng thái hợp lý và không trùng business key sau khi seed. Đối chiếu các view báo cáo với dữ liệu seed. Commit: `test(seed): validate demo data consistency`.

## Ngày 16/09/2026 - Procedures, functions và workflow

### Prompt 11 - Kiểm thử procedure tạo submission

Phân tích `submission.usp_create_submission` và các rule BR-P-005, BR-P-006, BR-P-009. Viết test table-driven cho submission hợp lệ, owner không khớp frame, frame đã dùng trong cùng contest, frame được dùng ở contest khác, deadline hết hạn và status không hợp lệ. Kiểm tra transaction không để lại bản ghi một phần. Commit: `test(sql): cover submission procedure rules`.

### Prompt 12 - Kiểm thử procedure verification

Phân tích `verification.usp_record_verification_decision`. Bổ sung test chứng minh AI flag chỉ là advisory, human review là bắt buộc để chốt quyết định, terminal status không bị sửa trái phép và submission không tồn tại bị từ chối. Kiểm tra rollback khi một điều kiện thất bại. Commit: `test(sql): validate human verification workflow`.

### Prompt 13 - Kiểm thử procedure finalize results

Phân tích `result.usp_finalize_results_for_round`. Tạo test cho round chưa đủ judging, score thiếu, tie/rank conflict, finalize thành công, gọi lại procedure và thay đổi sau khi finalize. Xác nhận procedure có tính idempotent hoặc trả lỗi rõ ràng theo thiết kế. Commit: `test(sql): validate result finalization workflow`.

### Prompt 14 - Kiểm thử scalar/table-valued functions

Kiểm kê `database/05_functions.sql` và các call site. Với mỗi function, tạo test giá trị bình thường, null, biên, không tìm thấy dữ liệu và dữ liệu nhiều dòng nếu function trả bảng. Kiểm tra kết quả bằng expected set, không chỉ kiểm tra có chạy không. Commit: `test(sql): cover database function behavior`.

### Prompt 15 - Kiểm thử transaction và lỗi giữa chừng

Chọn các procedure ghi nhiều bảng và dùng transaction. Dùng một input cố ý vi phạm ở bước sau để xác minh toàn bộ thao tác rollback, không tạo orphan rows và không để transaction mở. Kiểm tra `XACT_STATE()`/`@@TRANCOUNT` sau test. Cập nhật tài liệu nếu transaction contract chưa được mô tả. Commit: `test(sql): verify transactional rollback behavior`.

## Ngày 17/09/2026 - Views, triggers, audit và archive

### Prompt 16 - Kiểm thử reporting views

Rà soát `database/04_views.sql` và các view được nêu trong README. Đối chiếu kết quả view với truy vấn nguồn độc lập trên seed data; kiểm tra join không nhân bản dòng, dòng thiếu liên kết và filter trạng thái. Ghi expected columns/semantics cho từng view trong RTM hoặc validation notes. Commit: `test(reporting): validate reporting view semantics`.

### Prompt 17 - Kiểm thử audit trigger

Phân tích `database/07_triggers.sql` và audit requirement FR-029. Bổ sung test cho insert/update trạng thái ở các aggregate chính, kiểm tra actor/context nếu thiết kế hỗ trợ, old/new value, timestamp và không ghi audit giả khi update không đổi giá trị. Commit: `test(audit): validate status change history`.

### Prompt 18 - Kiểm thử trigger và recursive side effects

Kiểm tra mọi trigger có nguy cơ tác động chéo hoặc chạy lặp. Viết test multi-row statement, update nhiều bản ghi một lần, nested trigger nếu có và lỗi giữa batch. Xác minh trigger xử lý theo tập hợp, không giả định chỉ có một row và không tạo dữ liệu ngoài ý muốn. Commit: `test(sql): validate set-based trigger behavior`.

### Prompt 19 - Kiểm thử archive snapshot

Phân tích `archive.ArchiveItem` và `TST-ARC-001`. Bổ sung kiểm tra archive chỉ sinh từ result finalized, snapshot vẫn giữ nguyên sau khi dữ liệu live thay đổi, không tạo duplicate archive và không bị cascade delete. Commit: `test(archive): validate historical snapshot stability`.

### Prompt 20 - Kiểm thử restricted deletion

Mở rộng `TST-RET-001` thành ma trận delete protection cho registration, submission, evaluation, result và archive. Với mỗi entity, xác nhận hành vi `NO ACTION`/policy đúng thiết kế, dữ liệu lịch sử còn nguyên và status transition là đường thay thế khi cần vô hiệu hóa. Commit: `test(sql): cover historical deletion protections`.

## Ngày 18/09/2026 - Tích hợp, dữ liệu biên và chất lượng tự động

### Prompt 21 - Kiểm thử multi-round judging

Rà soát `TST-JDG-002` và các bảng judging. Tạo ma trận round 1/round 2 với judge khác nhau, criterion khác nhau, evaluation hợp lệ và evaluation nhầm round. Xác nhận unique key và result finalization không trộn dữ liệu giữa các round. Commit: `test(judging): expand multi-round isolation coverage`.

### Prompt 22 - Kiểm thử concurrency và duplicate submission

Thiết kế kịch bản hai session cùng cố tạo registration/submission hoặc evaluation. Dùng transaction/isolation phù hợp để mô phỏng trong SQL Server, xác nhận unique constraint/procedure bảo vệ dữ liệu và không có deadlock không được xử lý. Ghi rõ giới hạn nếu không thể chạy tự động trong môi trường hiện tại. Commit: `test(sql): probe concurrent duplicate protection`.

### Prompt 23 - Kiểm thử nullability và dữ liệu bẩn

Sinh ma trận dữ liệu bẩn cho các cột bắt buộc, URI/path, tên hiển thị, email, date và status. Xác nhận lỗi nằm ở đúng lớp (NOT NULL, CHECK, FK hoặc procedure), thông báo không làm lộ secret và cleanup luôn chạy. Commit: `test(sql): cover malformed and nullable inputs`.

### Prompt 24 - Kiểm thử truy vấn orphan và consistency

Viết một bộ consistency queries quét toàn bộ kho dữ liệu để tìm orphan rows, duplicate business keys, archive thiếu result, submission thiếu frame và audit thiếu aggregate. Các truy vấn phải trả về zero rows khi dữ liệu hợp lệ và có mã kiểm tra rõ ràng. Tích hợp vào validation runner hoặc tài liệu vận hành. Commit: `test(sql): add cross-table consistency checks`.

### Prompt 25 - Kiểm tra hiệu năng tối thiểu và index coverage

Đối chiếu truy vấn trong views/procedures/tests với `database/03_indexes.sql`. Dùng execution plan hoặc thống kê phù hợp để tìm scan bất thường, join thiếu index và index không phục vụ business key. Chỉ thêm/sửa index khi có bằng chứng và kiểm tra không làm đổi kết quả. Commit: `test(performance): validate critical query index coverage`.

## Ngày 19/09/2026 - Đóng băng, RTM và báo cáo chất lượng

### Prompt 26 - Chạy full validation gate

Chạy toàn bộ database initialization, seed, `tests/00_run_all_tests.sql`, consistency queries và các kiểm tra tài liệu. Lập bảng pass/fail/blocked với thời gian, môi trường, commit SHA và log lỗi. Không đánh dấu pass cho test chưa chạy được. Commit: `docs(validation): record full validation gate results`.

### Prompt 27 - Hoàn thiện RTM hai chiều

Cập nhật `docs/07_validation_traceability.md` để truy vết hai chiều: từ FR/NFR/BR đến test và từ từng test đến requirement/rule. Bổ sung các test mới của tuần, đánh dấu uncovered requirement, duplicate coverage và coverage chỉ ở mức tài liệu. Commit: `docs(rtm): complete bidirectional traceability`.

### Prompt 28 - Kiểm tra tài liệu và mã không lệch nhau

Đối chiếu README, project freeze, architecture, physical design, assignment, RTM, database scripts và test runner. Sửa đường dẫn cũ, tên file sai, DBMS/port không nhất quán, số lượng test sai và hướng dẫn không còn chạy được. Không thay đổi nội dung nghiệp vụ nếu không có bằng chứng. Commit: `docs(validation): align operational documentation`.

### Prompt 29 - Đánh giá release regression risk

Lập regression checklist theo module: IAM, contest, registration, film, submission, verification, judging, result, archive, audit/reporting. Xác định test smoke bắt buộc, test đầy đủ, rủi ro còn lại và owner xử lý. Cập nhật project freeze criteria với bằng chứng, không che khuất blocker. Commit: `docs(validation): publish regression risk assessment`.

### Prompt 30 - Đóng gói báo cáo Testing & Validation Lead

Tạo báo cáo tổng kết gồm phạm vi đã kiểm tra, số test pass/fail/blocked, coverage RTM, lỗi phát hiện và đã sửa, gap còn lại, bằng chứng môi trường, hướng dẫn chạy lại và đề xuất release decision. Kiểm tra working tree sạch ngoài thay đổi dự kiến, review diff, chạy smoke test cuối và tạo commit tổng kết. Commit: `docs(validation): finalize testing and validation report`.

## Tiêu chí hoàn thành ngày 19/09

- 30 prompt đã được xử lý hoặc có trạng thái `blocked` kèm nguyên nhân và bằng chứng.
- Full test runner chạy được hoặc có log lỗi môi trường cụ thể.
- Mọi test mới có mã duy nhất, setup/cleanup và liên kết RTM.
- Không còn link tài liệu, tên test hoặc hướng dẫn khởi tạo bị sai.
- RTM phân biệt rõ coverage đã chạy, coverage chỉ đọc tĩnh và gap chưa được kiểm chứng.
- Commit history thể hiện được phạm vi kiểm thử theo từng ngày, không gộp các thay đổi không liên quan.