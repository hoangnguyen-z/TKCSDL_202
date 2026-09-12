# Team Assignment

## Trung Châu

- **Vai trò:** Requirement Lead
- **GitHub account:** `Pinginguyen`
- **Commit email:** `trungchau1210@gmail.com`
- **GitHub repository:** [hoangnguyen-z/TKCSDL_202](https://github.com/hoangnguyen-z/TKCSDL_202)
- **Phạm vi phụ trách:** Requirement Analysis và các đầu vào nghiệp vụ làm cơ sở cho thiết kế kiến trúc, CSDL và kiểm thử.

## Owned Artifacts

| Artifact | Nội dung chịu trách nhiệm |
| --- | --- |
| [docs/01_gap_analysis.md](01_gap_analysis.md) | Xác định hiện trạng, phạm vi thiếu và chiến lược lấp đầy khoảng trống |
| [docs/02_requirement_analysis.md](02_requirement_analysis.md) | Business problem, scope, glossary, stakeholders, RBAC baseline, AS-IS/TO-BE, core flows, FR, NFR, BR và use cases |
| [latex-book-main/chapter1.tex](../latex-book-main/chapter1.tex) | Bối cảnh, pain points, mục tiêu, phạm vi, glossary và stakeholder analysis trong báo cáo LaTeX |
| [latex-book-main/chapter2.tex](../latex-book-main/chapter2.tex) | AS-IS/TO-BE, core business flows, FR, NFR, BR và use-case specifications trong báo cáo LaTeX |

Các artifact trên được duy trì theo đúng phạm vi Requirement Lead; phần triển khai SQL, Docker và test runtime có thể do thành viên khác thực hiện nhưng phải nhận được requirement inputs và giữ liên kết traceability.

## Traceability Responsibility

Requirement Lead chịu trách nhiệm duy trì tính nhất quán của requirement IDs và các liên kết sau:

`Source requirements -> Business flows -> FR/NFR/BR -> Use cases -> Architecture and database artifacts -> Tests`

Các thay đổi requirement cần được đối chiếu với [docs/07_validation_traceability.md](07_validation_traceability.md) trước khi merge.

### Requirement Review Checklist

Trước khi chấp nhận một thay đổi requirement, Requirement Lead kiểm tra:

1. Source requirement và phạm vi thay đổi đã được xác định.
2. Flow, FR/NFR/BR và use case liên quan đã được cập nhật.
3. Tác động tới architecture, database artifact và test đã được ghi nhận.
4. Official requirement được phân biệt với proposed rule hoặc design decision.
5. Các ID và liên kết trong RTM không bị trùng hoặc đứt.