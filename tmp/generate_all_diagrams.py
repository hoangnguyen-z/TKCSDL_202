# -*- coding: utf-8 -*-
"""
Perfected Publication-Grade Diagram Generator for TKCSDL Project.
Generates 7 meticulously aligned, razor-sharp diagrams matching the reference sample style.
"""

import os
from pathlib import Path
from playwright.sync_api import sync_playwright

OUTPUT_DIR_LATEX = Path(r"d:\dự án TKCSDL\latex-book-main\figures")
OUTPUT_DIR_DOCS = Path(r"d:\dự án TKCSDL\docs\figures")

OUTPUT_DIR_LATEX.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR_DOCS.mkdir(parents=True, exist_ok=True)


def get_html_wrapper(svg_content, caption_text, width=1520, height=1050):
    return f"""<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    background-color: #ffffff;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-family: 'Times New Roman', 'Arial', sans-serif;
    padding: 20px;
  }}
  .diagram-container {{
    border: 2px solid #000000;
    background-color: #ffffff;
    padding: 16px;
    box-shadow: none;
    width: {width}px;
    height: {height}px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
  }}
  .caption {{
    margin-top: 14px;
    font-size: 20px;
    font-style: italic;
    font-family: 'Times New Roman', serif;
    color: #000000;
    text-align: center;
  }}
</style>
</head>
<body>
  <div class="diagram-container">
    {svg_content}
  </div>
  <div class="caption">{caption_text}</div>
</body>
</html>"""


# ==============================================================================
# 1. SƠ ĐỒ USE CASE (USE CASE DIAGRAM)
# ==============================================================================
def generate_use_case_svg():
    w, h = 1460, 960
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    <defs>
      <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#000000"/>
      </marker>
      <marker id="open-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
        <path d="M 0 1 L 9 5 L 0 9" fill="none" stroke="#000000" stroke-width="1.3"/>
      </marker>
    </defs>

    <!-- System Boundary Box -->
    <rect x="250" y="30" width="940" height="900" rx="8" fill="#fafafa" stroke="#000000" stroke-width="2" stroke-dasharray="8,5"/>
    <text x="720" y="62" text-anchor="middle" font-size="16" font-weight="bold" fill="#000000" letter-spacing="1">HỆ THỐNG QUẢN LÝ CUỘC THI NHIẾP ẢNH PHIM TÍCH HỢP AI</text>

    <!-- Subsystem Boxes -->
    <rect x="270" y="85" width="900" height="200" rx="6" fill="#ffffff" stroke="#888888" stroke-width="1.2" stroke-dasharray="4,4"/>
    <text x="290" y="108" font-size="12.5" font-weight="bold" fill="#003366">PHÂN HỆ 1: THÍ SINH, ĐĂNG KÝ &amp; KHAI BÁO TÀI SẢN PHIM</text>

    <rect x="270" y="300" width="900" height="235" rx="6" fill="#ffffff" stroke="#888888" stroke-width="1.2" stroke-dasharray="4,4"/>
    <text x="290" y="323" font-size="12.5" font-weight="bold" fill="#003366">PHÂN HỆ 2: BAN TỔ CHỨC &amp; THẨM ĐỊNH AI HUMAN-IN-THE-LOOP</text>

    <rect x="270" y="550" width="900" height="175" rx="6" fill="#ffffff" stroke="#888888" stroke-width="1.2" stroke-dasharray="4,4"/>
    <text x="290" y="573" font-size="12.5" font-weight="bold" fill="#003366">PHÂN HỆ 3: HỘI ĐỒNG GIÁM KHẢO &amp; CHẤM THI NHIỀU VÒNG</text>

    <rect x="270" y="740" width="900" height="175" rx="6" fill="#ffffff" stroke="#888888" stroke-width="1.2" stroke-dasharray="4,4"/>
    <text x="290" y="763" font-size="12.5" font-weight="bold" fill="#003366">PHÂN HỆ 4: QUẢN TRỊ HỆ THỐNG, DANH MỤC &amp; AUDIT LOG</text>

    <!-- ACTORS -->
    <!-- Actor 1: Thí sinh -->
    <g transform="translate(80, 140)">
      <circle cx="35" cy="20" r="15" fill="#ffffff" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="35" x2="35" y2="75" stroke="#000000" stroke-width="2"/>
      <line x1="5" y1="50" x2="65" y2="50" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="10" y2="115" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="60" y2="115" stroke="#000000" stroke-width="2"/>
      <text x="35" y="135" text-anchor="middle" font-size="13" font-weight="bold">Thí sinh</text>
      <text x="35" y="152" text-anchor="middle" font-size="11" fill="#444444">(Participant)</text>
    </g>

    <!-- Actor 2: Ban tổ chức -->
    <g transform="translate(80, 370)">
      <circle cx="35" cy="20" r="15" fill="#ffffff" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="35" x2="35" y2="75" stroke="#000000" stroke-width="2"/>
      <line x1="5" y1="50" x2="65" y2="50" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="10" y2="115" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="60" y2="115" stroke="#000000" stroke-width="2"/>
      <text x="35" y="135" text-anchor="middle" font-size="13" font-weight="bold">Ban tổ chức</text>
      <text x="35" y="152" text-anchor="middle" font-size="11" fill="#444444">(Organizer)</text>
    </g>

    <!-- Actor 3: Giám khảo -->
    <g transform="translate(1310, 570)">
      <circle cx="35" cy="20" r="15" fill="#ffffff" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="35" x2="35" y2="75" stroke="#000000" stroke-width="2"/>
      <line x1="5" y1="50" x2="65" y2="50" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="10" y2="115" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="60" y2="115" stroke="#000000" stroke-width="2"/>
      <text x="35" y="135" text-anchor="middle" font-size="13" font-weight="bold">Giám khảo</text>
      <text x="35" y="152" text-anchor="middle" font-size="11" fill="#444444">(Judge)</text>
    </g>

    <!-- Actor 4: Quản trị viên -->
    <g transform="translate(1310, 760)">
      <circle cx="35" cy="20" r="15" fill="#ffffff" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="35" x2="35" y2="75" stroke="#000000" stroke-width="2"/>
      <line x1="5" y1="50" x2="65" y2="50" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="10" y2="115" stroke="#000000" stroke-width="2"/>
      <line x1="35" y1="75" x2="60" y2="115" stroke="#000000" stroke-width="2"/>
      <text x="35" y="135" text-anchor="middle" font-size="13" font-weight="bold">Quản trị viên</text>
      <text x="35" y="152" text-anchor="middle" font-size="11" fill="#444444">(System Admin)</text>
    </g>

    <!-- USE CASES (OVALS) -->
    <!-- Phân hệ 1 UCs -->
    <g transform="translate(350, 130)">
      <ellipse cx="100" cy="22" rx="95" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="100" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-03: Đăng ký Cuộc thi</text>
    </g>
    <g transform="translate(620, 130)">
      <ellipse cx="115" cy="22" rx="110" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="115" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-04: Khai báo Cuộn &amp; Khung phim</text>
    </g>
    <g transform="translate(450, 215)">
      <ellipse cx="105" cy="22" rx="100" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="105" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-05: Nộp Bài dự thi</text>
    </g>
    <g transform="translate(770, 215)">
      <ellipse cx="115" cy="22" rx="110" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="115" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-09: Xem Kết quả &amp; Di sản</text>
    </g>

    <!-- Phân hệ 2 UCs -->
    <g transform="translate(340, 350)">
      <ellipse cx="115" cy="22" rx="110" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="115" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-01: Cấu hình Cuộc thi &amp; Hạng mục</text>
    </g>
    <g transform="translate(630, 350)">
      <ellipse cx="105" cy="22" rx="100" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="105" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-02: Duyệt Đăng ký Thí sinh</text>
    </g>
    <g transform="translate(380, 435)">
      <ellipse cx="125" cy="25" rx="120" ry="25" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="125" y="23" text-anchor="middle" font-size="11.5" font-weight="600">UC-06: Thẩm định Bài thi</text>
      <text x="125" y="38" text-anchor="middle" font-size="10.5" fill="#444444">&amp; Xử lý Cảnh báo AI</text>
    </g>
    <g transform="translate(730, 435)">
      <ellipse cx="120" cy="25" rx="115" ry="25" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="120" y="23" text-anchor="middle" font-size="11.5" font-weight="600">Tiếp nhận Phân tích AI</text>
      <text x="120" y="38" text-anchor="middle" font-size="10.5" fill="#444444">(Tương đồng &amp; Phát hiện AI)</text>
    </g>
    <g transform="translate(540, 485)">
      <ellipse cx="125" cy="22" rx="120" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="125" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-08: Tổng hợp Điểm &amp; Gán Giải</text>
    </g>

    <!-- Phân hệ 3 UCs -->
    <g transform="translate(480, 610)">
      <ellipse cx="130" cy="25" rx="125" ry="25" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="130" y="23" text-anchor="middle" font-size="11.5" font-weight="600">UC-07: Chấm thi &amp; Đánh giá</text>
      <text x="130" y="38" text-anchor="middle" font-size="10.5" fill="#444444">theo Tiêu chí &amp; Trọng số</text>
    </g>
    <g transform="translate(850, 610)">
      <ellipse cx="115" cy="22" rx="110" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="115" y="27" text-anchor="middle" font-size="11.5" font-weight="600">Xem Hồ sơ Bài thi &amp; Lab</text>
    </g>

    <!-- Phân hệ 4 UCs -->
    <g transform="translate(320, 810)">
      <ellipse cx="120" cy="22" rx="115" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="120" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-10: Quản trị User &amp; RBAC</text>
    </g>
    <g transform="translate(610, 810)">
      <ellipse cx="120" cy="22" rx="115" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="120" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-11: Quản trị Lab &amp; Thiết bị</text>
    </g>
    <g transform="translate(900, 810)">
      <ellipse cx="115" cy="22" rx="110" ry="22" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <text x="115" y="27" text-anchor="middle" font-size="11.5" font-weight="600">UC-12: Giám sát Audit Log</text>
    </g>

    <!-- ACTOR CONNECTIONS -->
    <!-- Participant Lines -->
    <line x1="145" y1="190" x2="355" y2="152" stroke="#000000" stroke-width="1.3"/>
    <line x1="145" y1="190" x2="455" y2="232" stroke="#000000" stroke-width="1.3"/>
    <line x1="145" y1="190" x2="775" y2="235" stroke="#000000" stroke-width="1.3"/>

    <!-- Organizer Lines -->
    <line x1="145" y1="420" x2="345" y2="370" stroke="#000000" stroke-width="1.3"/>
    <line x1="145" y1="420" x2="635" y2="370" stroke="#000000" stroke-width="1.3"/>
    <line x1="145" y1="420" x2="385" y2="455" stroke="#000000" stroke-width="1.3"/>
    <line x1="145" y1="420" x2="545" y2="505" stroke="#000000" stroke-width="1.3"/>

    <!-- Judge Lines -->
    <path d="M 1310 620 L 1220 620 L 735 635" fill="none" stroke="#000000" stroke-width="1.3"/>
    <line x1="1310" y1="620" x2="1075" y2="632" stroke="#000000" stroke-width="1.3"/>

    <!-- Admin Lines -->
    <path d="M 1310 810 L 1260 880 L 440 880 L 440 855" fill="none" stroke="#000000" stroke-width="1.3"/>
    <path d="M 1310 810 L 1270 860 L 730 860 L 730 855" fill="none" stroke="#000000" stroke-width="1.3"/>
    <line x1="1310" y1="810" x2="1130" y2="832" stroke="#000000" stroke-width="1.3"/>

    <!-- INCLUDES / EXTENDS -->
    <!-- UC-05 include UC-04 -->
    <path d="M 555 215 L 670 174" fill="none" stroke="#000000" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#open-arrow)"/>
    <text x="635" y="198" font-size="10.5" font-style="italic" fill="#333333">&lt;&lt;include&gt;&gt;</text>

    <!-- UC-06 extend AI -->
    <path d="M 730 460 L 625 460" fill="none" stroke="#000000" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#open-arrow)"/>
    <text x="675" y="452" font-size="10.5" font-style="italic" fill="#333333">&lt;&lt;extend&gt;&gt;</text>

    <!-- UC-07 include view -->
    <path d="M 735 635 L 850 635" fill="none" stroke="#000000" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#open-arrow)"/>
    <text x="792" y="627" font-size="10.5" font-style="italic" fill="#333333">&lt;&lt;include&gt;&gt;</text>
  </svg>"""
    return get_html_wrapper(svg, "Hình 1. Sơ đồ Use Case phân định các chức năng theo 4 vai trò người dùng trong hệ thống", 1520, 1020)


# ==============================================================================
# 2. SƠ ĐỒ NGỮ CẢNH HỆ THỐNG (SYSTEM CONTEXT DIAGRAM)
# ==============================================================================
def generate_system_context_svg():
    w, h = 1400, 920
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    <defs>
      <marker id="ctx-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#000000"/>
      </marker>
    </defs>

    <!-- Central System Box -->
    <rect x="460" y="280" width="480" height="350" rx="8" fill="#f8f9fa" stroke="#000000" stroke-width="2.2"/>
    <rect x="460" y="280" width="480" height="50" rx="8" fill="#e9ecef" stroke="#000000" stroke-width="1.5"/>
    <text x="700" y="312" text-anchor="middle" font-size="16" font-weight="bold" fill="#000000">HỆ THỐNG QUẢN LÝ CUỘC THI NHIẾP ẢNH PHIM</text>
    <text x="700" y="345" text-anchor="middle" font-size="12.5" font-weight="600" fill="#333333">(Film Photography Contest Management Platform)</text>
    
    <!-- Central Subsystems List -->
    <g transform="translate(485, 370)">
      <rect x="0" y="0" width="430" height="235" fill="#ffffff" stroke="#cccccc" stroke-width="1"/>
      <text x="15" y="25" font-size="11.5" font-weight="bold" fill="#000000">• Quản lý Người dùng &amp; Phân quyền RBAC (iam)</text>
      <text x="15" y="50" font-size="11.5" font-weight="bold" fill="#000000">• Cấu hình Cuộc thi, Vòng chấm &amp; Tiêu chí (contest)</text>
      <text x="15" y="75" font-size="11.5" font-weight="bold" fill="#000000">• Quản lý Xuất xứ Cuộn phim &amp; Khung hình Scan (film)</text>
      <text x="15" y="100" font-size="11.5" font-weight="bold" fill="#000000">• Tiếp nhận Bài thi &amp; Thẩm định AI Advisory (submission)</text>
      <text x="15" y="125" font-size="11.5" font-weight="bold" fill="#000000">• Điều phối Giám khảo &amp; Tổng hợp Điểm số (judging)</text>
      <text x="15" y="150" font-size="11.5" font-weight="bold" fill="#000000">• Xếp hạng, Gán giải &amp; Lưu trữ Di sản số (result / archive)</text>
      <text x="15" y="175" font-size="11.5" font-weight="bold" fill="#000000">• Danh mục Tham chiếu Lab, Thiết bị &amp; Audit Log (catalog / audit)</text>
      <text x="15" y="210" font-size="11" font-style="italic" fill="#666666">Cơ sở dữ liệu cốt lõi: Microsoft SQL Server 2022 (FilmContestDB)</text>
    </g>

    <!-- EXTERNAL ENTITIES -->
    <!-- 1. Thí sinh -->
    <rect x="50" y="70" width="270" height="115" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="185" y="98" text-anchor="middle" font-size="13.5" font-weight="bold">THÍ SINH (PARTICIPANT)</text>
    <text x="65" y="125" font-size="11">• Đăng ký tham gia cuộc thi</text>
    <text x="65" y="145" font-size="11">• Khai báo cuộn phim, lab &amp; nộp bài</text>
    <text x="65" y="165" font-size="11">• Nhận thông báo duyệt, kết quả &amp; giải</text>

    <!-- 2. Ban tổ chức -->
    <rect x="50" y="390" width="270" height="125" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="185" y="418" text-anchor="middle" font-size="13.5" font-weight="bold">BAN TỔ CHỨC (ORGANIZER)</text>
    <text x="65" y="445" font-size="11">• Cấu hình thể lệ, lịch trình &amp; tiêu chí</text>
    <text x="65" y="465" font-size="11">• Xét duyệt hồ sơ &amp; thẩm định bài thi</text>
    <text x="65" y="485" font-size="11">• Xử lý cờ cảnh báo AI Human-in-the-loop</text>
    <text x="65" y="505" font-size="11">• Khóa vòng, xếp hạng &amp; công bố giải</text>

    <!-- 3. Giám khảo -->
    <rect x="50" y="720" width="270" height="115" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="185" y="748" text-anchor="middle" font-size="13.5" font-weight="bold">GIÁM KHẢO (JUDGE)</text>
    <text x="65" y="775" font-size="11">• Tiếp nhận danh sách bài thi phân công</text>
    <text x="65" y="795" font-size="11">• Xem thông số máy ảnh, cuộn phim &amp; scan</text>
    <text x="65" y="815" font-size="11">• Nhập phiếu điểm tiêu chí &amp; nhận xét</text>

    <!-- 4. Quản trị viên & SSMS Client -->
    <rect x="1080" y="70" width="270" height="125" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="1215" y="98" text-anchor="middle" font-size="13.5" font-weight="bold">QUẢN TRỊ VIÊN &amp; SSMS 22</text>
    <text x="1095" y="125" font-size="11">• Quản trị User, phân quyền RBAC</text>
    <text x="1095" y="145" font-size="11">• Kết nối trực tiếp SQL Server qua port 14333</text>
    <text x="1095" y="165" font-size="11">• Quản lý danh mục, backup &amp; audit log</text>
    <text x="1095" y="185" font-size="11">• Thực thi DDL, Stored Procedures &amp; Tests</text>

    <!-- 5. Dịch vụ Phân tích AI -->
    <rect x="1080" y="390" width="270" height="125" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="1215" y="418" text-anchor="middle" font-size="13.5" font-weight="bold">AI ADVISORY SERVICE</text>
    <text x="1095" y="445" font-size="11">• Tiếp nhận ảnh scan bài dự thi</text>
    <text x="1095" y="465" font-size="11">• Tính toán độ tương đồng ảnh (similarity)</text>
    <text x="1095" y="485" font-size="11">• Phát hiện dấu vết ảnh sinh AI (synthetic)</text>
    <text x="1095" y="505" font-size="11">• Trả về điểm tin cậy &amp; cờ tư vấn (advisory)</text>

    <!-- 6. Dịch vụ Lưu trữ Đối tượng -->
    <rect x="1080" y="720" width="270" height="115" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="1215" y="748" text-anchor="middle" font-size="13.5" font-weight="bold">CLOUD OBJECT STORAGE</text>
    <text x="1095" y="775" font-size="11">• Lưu trữ tệp ảnh scan độ phân giải cao</text>
    <text x="1095" y="795" font-size="11">• Lưu trữ chứng từ hóa đơn lab tráng phim</text>
    <text x="1095" y="815" font-size="11">• Cấp phát URI an toàn (Pre-signed URL)</text>

    <!-- DATA FLOW ARROWS -->
    <!-- Participant Flow -->
    <path d="M 320 110 L 460 295" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <path d="M 460 315 L 320 130" fill="none" stroke="#555555" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#ctx-arrow)"/>
    <text x="345" y="205" font-size="10.5" font-weight="600" transform="rotate(38, 345, 205)">Đơn ĐK, Metadata, Bài thi</text>

    <!-- Organizer Flow -->
    <path d="M 320 435 L 460 435" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <path d="M 460 465 L 320 465" fill="none" stroke="#555555" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#ctx-arrow)"/>
    <text x="340" y="428" font-size="10.5" font-weight="600">Thể lệ, Duyệt, Thẩm định</text>
    <text x="340" y="480" font-size="10.5" fill="#555555">Báo cáo, Cảnh báo AI</text>

    <!-- Judge Flow -->
    <path d="M 320 760 L 460 600" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <path d="M 460 580 L 320 740" fill="none" stroke="#555555" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#ctx-arrow)"/>
    <text x="330" y="675" font-size="10.5" font-weight="600" transform="rotate(-38, 330, 675)">Phiếu điểm &amp; Nhận xét</text>

    <!-- Admin & SSMS Flow -->
    <path d="M 1080 140 L 940 295" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <path d="M 940 315 L 1080 160" fill="none" stroke="#555555" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#ctx-arrow)"/>
    <text x="990" y="215" font-size="10.5" font-weight="600" transform="rotate(-38, 990, 215)">T-SQL / SSMS / RBAC</text>

    <!-- AI Service Flow -->
    <path d="M 940 435 L 1080 435" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <path d="M 1080 465 L 940 465" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <text x="955" y="428" font-size="10.5" font-weight="600">Gửi ảnh scan bài thi</text>
    <text x="955" y="480" font-size="10.5" font-weight="600">Điểm tương đồng &amp; Cờ AI</text>

    <!-- Object Storage Flow -->
    <path d="M 940 600 L 1080 750" fill="none" stroke="#000000" stroke-width="1.3" marker-end="url(#ctx-arrow)"/>
    <path d="M 1080 770 L 940 620" fill="none" stroke="#555555" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#ctx-arrow)"/>
    <text x="995" y="695" font-size="10.5" font-weight="600" transform="rotate(38, 995, 695)">Upload tệp / Trả về URI</text>
  </svg>"""
    return get_html_wrapper(svg, "Hình 2. Sơ đồ Ngữ cảnh hệ thống thể hiện ranh giới và tương tác với các tác nhân bên ngoài", 1440, 960)


# ==============================================================================
# 3. SƠ ĐỒ KIẾN TRÚC TỔNG THỂ (SYSTEM ARCHITECTURE DIAGRAM)
# ==============================================================================
def generate_system_architecture_svg():
    w, h = 1400, 940
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    <defs>
      <marker id="arch-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#000000"/>
      </marker>
    </defs>

    <!-- LAYER 1: PRESENTATION LAYER -->
    <rect x="40" y="25" width="1320" height="125" rx="6" fill="#f8f9fa" stroke="#000000" stroke-width="1.8"/>
    <text x="60" y="50" font-size="13.5" font-weight="bold" fill="#000000">TẦNG TRÌNH DIỄN (PRESENTATION &amp; CLIENT TIER)</text>
    
    <g transform="translate(60, 65)">
      <rect x="0" y="0" width="225" height="65" rx="4" fill="#ffffff" stroke="#333333" stroke-width="1.2"/>
      <text x="112" y="26" text-anchor="middle" font-size="12" font-weight="bold">Participant Web Portal</text>
      <text x="112" y="46" text-anchor="middle" font-size="10.5" fill="#555555">Đăng ký, Khai báo &amp; Nộp bài</text>
    </g>
    <g transform="translate(315, 65)">
      <rect x="0" y="0" width="225" height="65" rx="4" fill="#ffffff" stroke="#333333" stroke-width="1.2"/>
      <text x="112" y="26" text-anchor="middle" font-size="12" font-weight="bold">Organizer Console</text>
      <text x="112" y="46" text-anchor="middle" font-size="10.5" fill="#555555">Cấu hình, Thẩm định &amp; Trao giải</text>
    </g>
    <g transform="translate(570, 65)">
      <rect x="0" y="0" width="225" height="65" rx="4" fill="#ffffff" stroke="#333333" stroke-width="1.2"/>
      <text x="112" y="26" text-anchor="middle" font-size="12" font-weight="bold">Judge Evaluation UI</text>
      <text x="112" y="46" text-anchor="middle" font-size="10.5" fill="#555555">Chấm thi &amp; Đánh giá Tiêu chí</text>
    </g>
    <g transform="translate(825, 65)">
      <rect x="0" y="0" width="225" height="65" rx="4" fill="#ffffff" stroke="#333333" stroke-width="1.2"/>
      <text x="112" y="26" text-anchor="middle" font-size="12" font-weight="bold">Public Gallery / Archive</text>
      <text x="112" y="46" text-anchor="middle" font-size="10.5" fill="#555555">Tra cứu Triển lãm &amp; Di sản số</text>
    </g>
    <g transform="translate(1080, 65)">
      <rect x="0" y="0" width="250" height="65" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <text x="125" y="26" text-anchor="middle" font-size="12" font-weight="bold">SSMS 22 (DB Admin)</text>
      <text x="125" y="46" text-anchor="middle" font-size="10.5" fill="#555555">Direct T-SQL Client (Port 14333)</text>
    </g>

    <!-- CONNECTOR ARROWS -->
    <line x1="700" y1="150" x2="700" y2="185" stroke="#000000" stroke-width="1.6" marker-end="url(#arch-arrow)"/>

    <!-- LAYER 2: API GATEWAY & SECURITY LAYER -->
    <rect x="40" y="185" width="1320" height="80" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="60" y="208" font-size="13" font-weight="bold" fill="#000000">TẦNG CỔNG GIAO TIẾP &amp; BẢO MẬT (API GATEWAY &amp; SECURITY INTERCEPTOR)</text>
    
    <g transform="translate(60, 222)">
      <rect x="0" y="0" width="280" height="32" rx="3" fill="#f0f0f0" stroke="#666666" stroke-width="1"/>
      <text x="140" y="21" text-anchor="middle" font-size="11" font-weight="600">HTTPS / REST API Gateway</text>
    </g>
    <g transform="translate(380, 222)">
      <rect x="0" y="0" width="280" height="32" rx="3" fill="#f0f0f0" stroke="#666666" stroke-width="1"/>
      <text x="140" y="21" text-anchor="middle" font-size="11" font-weight="600">Authentication &amp; RBAC Token Validator</text>
    </g>
    <g transform="translate(700, 222)">
      <rect x="0" y="0" width="280" height="32" rx="3" fill="#f0f0f0" stroke="#666666" stroke-width="1"/>
      <text x="140" y="21" text-anchor="middle" font-size="11" font-weight="600">Input Validation &amp; Rate Limiter</text>
    </g>
    <g transform="translate(1020, 222)">
      <rect x="0" y="0" width="310" height="32" rx="3" fill="#f0f0f0" stroke="#666666" stroke-width="1"/>
      <text x="155" y="21" text-anchor="middle" font-size="11" font-weight="600">Audit Logging &amp; Actor Interceptor</text>
    </g>

    <!-- CONNECTOR ARROWS -->
    <line x1="700" y1="265" x2="700" y2="300" stroke="#000000" stroke-width="1.6" marker-end="url(#arch-arrow)"/>

    <!-- LAYER 3: BUSINESS LOGIC & 11 MODULES -->
    <rect x="40" y="300" width="1320" height="295" rx="6" fill="#fcfcfc" stroke="#000000" stroke-width="1.8"/>
    <text x="60" y="325" font-size="13.5" font-weight="bold" fill="#000000">TẦNG LOGIC NGHIỆP VỤ &amp; 11 PHÂN HỆ CHỨC NĂNG (APPLICATION CORE MODULES)</text>

    <!-- Column 1 -->
    <g transform="translate(60, 340)">
      <rect x="0" y="0" width="390" height="68" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="12" font-weight="bold">M01: Identity &amp; Access (iam)</text>
      <text x="15" y="42" font-size="10.5" fill="#555555">Quản lý User, Roles, User_Roles &amp; Participant Profile</text>
      <text x="15" y="58" font-size="10" font-style="italic" fill="#0066cc">Write: users, roles, user_roles</text>
    </g>
    <g transform="translate(60, 420)">
      <rect x="0" y="0" width="390" height="68" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="12" font-weight="bold">M02: Contest Management (contest)</text>
      <text x="15" y="42" font-size="10.5" fill="#555555">Cấu hình cuộc thi, hạng mục, vòng thi &amp; tiêu chí</text>
      <text x="15" y="58" font-size="10" font-style="italic" fill="#0066cc">Write: contests, contest_categories, rounds</text>
    </g>
    <g transform="translate(60, 500)">
      <rect x="0" y="0" width="390" height="68" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="12" font-weight="bold">M03: Registration Management</text>
      <text x="15" y="42" font-size="10.5" fill="#555555">Đăng ký tham gia &amp; xét duyệt điều kiện dự thi</text>
      <text x="15" y="58" font-size="10" font-style="italic" fill="#0066cc">Write: registrations</text>
    </g>

    <!-- Column 2 -->
    <g transform="translate(485, 340)">
      <rect x="0" y="0" width="400" height="68" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="12" font-weight="bold">M04: Film Asset &amp; Provenance (film)</text>
      <text x="15" y="42" font-size="10.5" fill="#555555">Quản lý cuộn phim, khung hình scan, ISO, lab</text>
      <text x="15" y="58" font-size="10" font-style="italic" fill="#0066cc">Write: film_rolls, film_frames</text>
    </g>
    <g transform="translate(485, 420)">
      <rect x="0" y="0" width="400" height="68" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="12" font-weight="bold">M05: Submission Management</text>
      <text x="15" y="42" font-size="10.5" fill="#555555">Tiếp nhận bài thi, ràng buộc 1 khung hình / 1 cuộc thi</text>
      <text x="15" y="58" font-size="10" font-style="italic" fill="#0066cc">Write: submissions</text>
    </g>
    <g transform="translate(485, 500)">
      <rect x="0" y="0" width="400" height="68" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="12" font-weight="bold">M06: Verification &amp; AI Human-in-the-Loop</text>
      <text x="15" y="42" font-size="10.5" fill="#555555">Thẩm định tính hợp lệ, tiếp nhận AI cờ cảnh báo tư vấn</text>
      <text x="15" y="58" font-size="10" font-style="italic" fill="#0066cc">Write: verification_cases, ai_analysis_results</text>
    </g>

    <!-- Column 3 -->
    <g transform="translate(920, 340)">
      <rect x="0" y="0" width="410" height="58" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="20" font-size="11" font-weight="bold">M07: Judging &amp; Scoring Engine</text>
      <text x="15" y="36" font-size="9.5" fill="#555555">Phân công giám khảo, chấm điểm tiêu chí có trọng số</text>
      <text x="15" y="50" font-size="9.5" font-style="italic" fill="#0066cc">Write: judge_assignments, evaluations, evaluation_scores</text>
    </g>
    <g transform="translate(920, 408)">
      <rect x="0" y="0" width="410" height="58" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="20" font-size="11" font-weight="bold">M08: Result Ranking &amp; Award</text>
      <text x="15" y="36" font-size="9.5" fill="#555555">Tổng hợp điểm, xếp hạng &amp; gán giải thưởng</text>
      <text x="15" y="50" font-size="9.5" font-style="italic" fill="#0066cc">Write: results, award_definitions, award_assignments</text>
    </g>
    <g transform="translate(920, 476)">
      <rect x="0" y="0" width="410" height="58" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="20" font-size="11" font-weight="bold">M09 &amp; M10: Digital Archive &amp; Catalogs</text>
      <text x="15" y="36" font-size="9.5" fill="#555555">Bản chụp bất biến tác phẩm đạt giải &amp; Danh mục lab/máy</text>
      <text x="15" y="50" font-size="9.5" font-style="italic" fill="#0066cc">Write: archive_items, film_stocks, cameras, lenses, labs</text>
    </g>
    <g transform="translate(920, 542)">
      <rect x="0" y="0" width="410" height="45" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="18" font-size="11" font-weight="bold">M11: Audit Trail &amp; System Views</text>
      <text x="15" y="35" font-size="9.5" font-style="italic" fill="#0066cc">Write: audit_logs (append-only) | Read-only Views</text>
    </g>

    <!-- CONNECTOR ARROWS -->
    <line x1="700" y1="595" x2="700" y2="630" stroke="#000000" stroke-width="1.6" marker-end="url(#arch-arrow)"/>

    <!-- LAYER 4: EXTERNAL INTEGRATION ADAPTERS -->
    <rect x="40" y="630" width="1320" height="75" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
    <text x="60" y="653" font-size="13" font-weight="bold" fill="#000000">TẦNG TÍCH HỢP DỊCH VỤ NGOÀI (EXTERNAL INTEGRATION LAYER)</text>

    <g transform="translate(160, 665)">
      <rect x="0" y="0" width="460" height="30" rx="3" fill="#f0f0f0" stroke="#333333" stroke-width="1"/>
      <text x="230" y="20" text-anchor="middle" font-size="11" font-weight="600">Cloud Object Storage Adapter (S3 / GCS Image Bucket)</text>
    </g>
    <g transform="translate(710, 665)">
      <rect x="0" y="0" width="550" height="30" rx="3" fill="#f0f0f0" stroke="#333333" stroke-width="1"/>
      <text x="275" y="20" text-anchor="middle" font-size="11" font-weight="600">AI Advisory Pipeline Engine (Async Similarity &amp; Synthetic Detector)</text>
    </g>

    <!-- CONNECTOR ARROWS -->
    <line x1="700" y1="705" x2="700" y2="740" stroke="#000000" stroke-width="1.6" marker-end="url(#arch-arrow)"/>

    <!-- LAYER 5: DATABASE TIER -->
    <rect x="40" y="740" width="1320" height="175" rx="6" fill="#f8f9fa" stroke="#000000" stroke-width="2"/>
    <text x="60" y="765" font-size="13.5" font-weight="bold" fill="#000000">TẦNG CƠ SỞ DỮ LIỆU (RELATIONAL DATABASE TIER - MICROSOFT SQL SERVER 2022 IN DOCKER)</text>

    <g transform="translate(60, 780)">
      <rect x="0" y="0" width="290" height="115" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="11.5" font-weight="bold">24 Relational Tables (3NF)</text>
      <text x="15" y="42" font-size="10" fill="#444444">• Phân chia 6 schema logic</text>
      <text x="15" y="60" font-size="10" fill="#444444">• Khóa chính PK Clustered</text>
      <text x="15" y="78" font-size="10" fill="#444444">• Khóa ngoại FK có ràng buộc</text>
      <text x="15" y="96" font-size="10" fill="#444444">• Chuẩn hóa triệt để 3NF</text>
    </g>
    <g transform="translate(385, 780)">
      <rect x="0" y="0" width="290" height="115" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="11.5" font-weight="bold">Integrity Constraints</text>
      <text x="15" y="42" font-size="10" fill="#444444">• CHECK (Status, Score 0-100, Weight)</text>
      <text x="15" y="60" font-size="10" fill="#444444">• UNIQUE (1 Frame / Contest, Email)</text>
      <text x="15" y="78" font-size="10" fill="#444444">• Date Ordering (Start &lt; End Date)</text>
      <text x="15" y="96" font-size="10" fill="#444444">• ON DELETE RESTRICT bảo toàn dữ liệu</text>
    </g>
    <g transform="translate(710, 780)">
      <rect x="0" y="0" width="290" height="115" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="11.5" font-weight="bold">Programmability (T-SQL)</text>
      <text x="15" y="42" font-size="10" fill="#444444">• SP Calculate Round Scores (Trọng số)</text>
      <text x="15" y="60" font-size="10" fill="#444444">• SP Finalize Award &amp; Snapshot</text>
      <text x="15" y="78" font-size="10" fill="#444444">• Function Scalar &amp; Inline TVF</text>
      <text x="15" y="96" font-size="10" fill="#444444">• Trigger Audit Log &amp; Immutability</text>
    </g>
    <g transform="translate(1035, 780)">
      <rect x="0" y="0" width="305" height="115" rx="4" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <text x="15" y="22" font-size="11.5" font-weight="bold">Indexes &amp; Views</text>
      <text x="15" y="42" font-size="10" fill="#444444">• Nonclustered Indexes trên FK, Status</text>
      <text x="15" y="60" font-size="10" fill="#444444">• Filtered Index cho Active Submissions</text>
      <text x="15" y="78" font-size="10" fill="#444444">• Views: Leaderboard, Audit, Gallery</text>
      <text x="15" y="96" font-size="10" fill="#444444">• Target: FilmContestDB (Port 14333)</text>
    </g>
  </svg>"""
    return get_html_wrapper(svg, "Hình 3. Sơ đồ Kiến trúc Tổng thể phân tầng, các phân hệ module và cơ sở dữ liệu quan hệ", 1440, 980)


# ==============================================================================
# 4. SƠ ĐỒ HOẠT ĐỘNG / LUỒNG NGHIỆP VỤ (ACTIVITY DIAGRAM / FLOWCHART)
# ==============================================================================
def generate_activity_workflow_svg():
    w, h = 1400, 940
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    <defs>
      <marker id="act-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#000000"/>
      </marker>
    </defs>

    <!-- SWIMLANE 1: QUY TRÌNH NỘP BÀI & THẨM ĐỊNH AI -->
    <rect x="40" y="25" width="1320" height="420" rx="6" fill="#fdfdfd" stroke="#000000" stroke-width="1.8"/>
    <rect x="40" y="25" width="1320" height="35" rx="6" fill="#e9ecef" stroke="#000000" stroke-width="1.2"/>
    <text x="700" y="49" text-anchor="middle" font-size="13.5" font-weight="bold" fill="#000000">LUỒNG 1: QUY TRÌNH NỘP BÀI THI, TIẾP NHẬN TƯ VẤN AI &amp; THẨM ĐỊNH XUẤT XỨ PHIM (SUBMISSION &amp; VERIFICATION)</text>

    <!-- Flow 1 Nodes -->
    <!-- Start Node -->
    <circle cx="80" cy="130" r="14" fill="#000000"/>
    <line x1="94" y1="130" x2="135" y2="130" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>

    <!-- Step 1 -->
    <rect x="135" y="100" width="175" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="222" y="125" text-anchor="middle" font-size="11" font-weight="600">[Thí sinh] Khai báo</text>
    <text x="222" y="142" text-anchor="middle" font-size="11" font-weight="600">Cuộn phim &amp; Khung hình</text>

    <!-- Step 2 -->
    <line x1="310" y1="130" x2="355" y2="130" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="355" y="100" width="175" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="442" y="125" text-anchor="middle" font-size="11" font-weight="600">[Thí sinh] Upload tệp scan</text>
    <text x="442" y="142" text-anchor="middle" font-size="11" font-weight="600">&amp; Đăng ký Hạng mục thi</text>

    <!-- Step 3 -->
    <line x1="530" y1="130" x2="575" y2="130" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="575" y="100" width="185" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="667" y="122" text-anchor="middle" font-size="11" font-weight="600">[Hệ thống] Lưu Storage,</text>
    <text x="667" y="137" text-anchor="middle" font-size="11" font-weight="600">Tạo bản ghi Submissions</text>
    <text x="667" y="152" text-anchor="middle" font-size="10" fill="#666666">(Trạng thái: PENDING)</text>

    <!-- Step 4 -->
    <line x1="760" y1="130" x2="805" y2="130" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="805" y="100" width="195" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="902" y="122" text-anchor="middle" font-size="11" font-weight="600">[AI Service] Quét tương đồng</text>
    <text x="902" y="137" text-anchor="middle" font-size="11" font-weight="600">&amp; Phân tích sinh ảnh AI</text>
    <text x="902" y="152" text-anchor="middle" font-size="10" fill="#666666">(ai_analysis_results)</text>

    <!-- Decision 1: AI Flagged? -->
    <line x1="1000" y1="130" x2="1050" y2="130" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <polygon points="1110,95 1170,130 1110,165 1050,130" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="1110" y="128" text-anchor="middle" font-size="10.5" font-weight="bold">AI gắn cờ</text>
    <text x="1110" y="142" text-anchor="middle" font-size="10.5" font-weight="bold">cảnh báo?</text>

    <!-- Branch: NO -->
    <path d="M 1110 95 L 1110 75 L 700 75 L 700 210 L 735 210" fill="none" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <text x="1030" y="70" font-size="11" font-weight="bold" fill="#008800">[Không / Điểm an toàn]</text>

    <!-- Branch: YES -->
    <line x1="1170" y1="130" x2="1230" y2="130" stroke="#000000" stroke-width="1.4"/>
    <path d="M 1230 130 L 1230 210 L 1135 210" fill="none" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <text x="1180" y="122" font-size="11" font-weight="bold" fill="#cc0000">[Có cờ nghi vấn]</text>

    <!-- Step 5: Ban tổ chức đối chiếu -->
    <rect x="915" y="180" width="220" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="1025" y="205" text-anchor="middle" font-size="11" font-weight="600">[Ban tổ chức] Thẩm định thủ công</text>
    <text x="1025" y="222" text-anchor="middle" font-size="11" font-weight="600">Đối chiếu cuộn phim &amp; lab</text>

    <!-- Decision 2: BTC Quyết định -->
    <line x1="915" y1="210" x2="865" y2="210" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <polygon points="810,175 865,210 810,245 755,210" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="810" y="208" text-anchor="middle" font-size="10.5" font-weight="bold">BTC phê</text>
    <text x="810" y="222" text-anchor="middle" font-size="10.5" font-weight="bold">duyệt?</text>

    <!-- Reject -->
    <line x1="810" y1="245" x2="810" y2="305" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <text x="820" y="280" font-size="11" font-weight="bold" fill="#cc0000">[Từ chối]</text>
    <rect x="720" y="305" width="180" height="50" rx="6" fill="#fff0f0" stroke="#cc0000" stroke-width="1.4"/>
    <text x="810" y="327" text-anchor="middle" font-size="11" font-weight="bold" fill="#cc0000">Ghi nhận REJECTED</text>
    <text x="810" y="343" text-anchor="middle" font-size="10" fill="#555555">Gửi lý do cho thí sinh</text>

    <!-- End Reject Node -->
    <line x1="810" y1="355" x2="810" y2="390" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <g transform="translate(810, 405)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
      <circle cx="0" cy="0" r="8" fill="#000000"/>
    </g>

    <!-- Approve -->
    <line x1="755" y1="210" x2="540" y2="210" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <text x="615" y="200" font-size="11" font-weight="bold" fill="#008800">[Hợp lệ / VERIFIED]</text>

    <rect x="340" y="180" width="200" height="60" rx="6" fill="#f0fff0" stroke="#008800" stroke-width="1.4"/>
    <text x="440" y="205" text-anchor="middle" font-size="11" font-weight="bold" fill="#008800">Cập nhật Status = VERIFIED</text>
    <text x="440" y="222" text-anchor="middle" font-size="10" fill="#333333">Ghi vết verification_cases &amp; Log</text>

    <!-- End Verified Node -->
    <line x1="340" y1="210" x2="200" y2="210" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <g transform="translate(185, 210)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
      <circle cx="0" cy="0" r="8" fill="#000000"/>
      <text x="0" y="32" text-anchor="middle" font-size="11" font-weight="600">Đủ điều kiện vào vòng chấm</text>
    </g>


    <!-- SWIMLANE 2: QUY TRÌNH CHẤM THI & TRAO GIẢI -->
    <rect x="40" y="470" width="1320" height="440" rx="6" fill="#fdfdfd" stroke="#000000" stroke-width="1.8"/>
    <rect x="40" y="470" width="1320" height="35" rx="6" fill="#e9ecef" stroke="#000000" stroke-width="1.2"/>
    <text x="700" y="494" text-anchor="middle" font-size="13.5" font-weight="bold" fill="#000000">LUỒNG 2: QUY TRÌNH PHÂN CÔNG, CHẤM THI NHIỀU VÒNG &amp; LƯU TRỮ DI SẢN (JUDGING &amp; AWARD)</text>

    <!-- Start Node 2 -->
    <circle cx="80" cy="570" r="14" fill="#000000"/>
    <line x1="94" y1="570" x2="135" y2="570" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>

    <!-- Step 1 -->
    <rect x="135" y="540" width="175" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="222" y="565" text-anchor="middle" font-size="11" font-weight="600">[Ban tổ chức] Mở vòng thi</text>
    <text x="222" y="582" text-anchor="middle" font-size="11" font-weight="600">&amp; Phân công Giám khảo</text>

    <!-- Step 2 -->
    <line x1="310" y1="570" x2="355" y2="570" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="355" y="540" width="185" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="447" y="565" text-anchor="middle" font-size="11" font-weight="600">[Giám khảo] Đánh giá &amp;</text>
    <text x="447" y="582" text-anchor="middle" font-size="11" font-weight="600">Nhập điểm theo Tiêu chí</text>

    <!-- Step 3 -->
    <line x1="540" y1="570" x2="585" y2="570" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="585" y="540" width="185" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="677" y="562" text-anchor="middle" font-size="11" font-weight="600">[Hệ thống] Kiểm tra</text>
    <text x="677" y="577" text-anchor="middle" font-size="11" font-weight="600">Ràng buộc Score [0-100]</text>
    <text x="677" y="592" text-anchor="middle" font-size="10" fill="#666666">&amp; Khóa phiếu SUBMITTED</text>

    <!-- Step 4 -->
    <line x1="770" y1="570" x2="815" y2="570" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="815" y="540" width="195" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="912" y="562" text-anchor="middle" font-size="11" font-weight="600">[BTC] Đóng vòng thi,</text>
    <text x="912" y="577" text-anchor="middle" font-size="11" font-weight="600">Chạy SP Tính Điểm</text>
    <text x="912" y="592" text-anchor="middle" font-size="10" fill="#666666">(Tính trung bình có trọng số)</text>

    <!-- Decision: Là vòng Chung khảo? -->
    <line x1="1010" y1="570" x2="1060" y2="570" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <polygon points="1120,535 1180,570 1120,605 1060,570" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="1120" y="568" text-anchor="middle" font-size="10.5" font-weight="bold">Là vòng</text>
    <text x="1120" y="582" text-anchor="middle" font-size="10.5" font-weight="bold">Chung khảo?</text>

    <!-- Branch: NO -->
    <path d="M 1120 535 L 1120 515 L 222 515 L 222 540" fill="none" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <text x="600" y="528" font-size="11" font-weight="bold" fill="#0066cc">[Không: Lọc Top bài thi vào Vòng tiếp theo]</text>

    <!-- Branch: YES -->
    <line x1="1120" y1="605" x2="1120" y2="650" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <text x="1130" y="630" font-size="11" font-weight="bold" fill="#008800">[Chung khảo]</text>

    <!-- Step 5: Gán giải -->
    <rect x="1015" y="650" width="210" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="1120" y="675" text-anchor="middle" font-size="11" font-weight="600">[Ban tổ chức] Gán cơ cấu giải</text>
    <text x="1120" y="692" text-anchor="middle" font-size="11" font-weight="600">(Nhất, Nhì, Ba, Khuyến khích)</text>

    <!-- Step 6: Snapshot Archive -->
    <line x1="1015" y1="680" x2="935" y2="680" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="715" y="650" width="220" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="825" y="672" text-anchor="middle" font-size="11" font-weight="600">[Hệ thống] Tạo Snapshot bất biến</text>
    <text x="825" y="687" text-anchor="middle" font-size="11" font-weight="600">Lưu trữ di sản (archive_items)</text>
    <text x="825" y="702" text-anchor="middle" font-size="10" fill="#666666">Cấm xóa vật lý (Restricted Delete)</text>

    <!-- Step 7: Công bố -->
    <line x1="715" y1="680" x2="635" y2="680" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <rect x="435" y="650" width="200" height="60" rx="6" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="535" y="675" text-anchor="middle" font-size="11" font-weight="600">Công bố Bảng Xếp hạng</text>
    <text x="535" y="692" text-anchor="middle" font-size="11" font-weight="600">&amp; Mở Triển lãm Trực tuyến</text>

    <!-- End Final Node -->
    <line x1="435" y1="680" x2="295" y2="680" stroke="#000000" stroke-width="1.4" marker-end="url(#act-arrow)"/>
    <g transform="translate(280, 680)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" stroke="#000000" stroke-width="1.8"/>
      <circle cx="0" cy="0" r="8" fill="#000000"/>
      <text x="0" y="32" text-anchor="middle" font-size="11" font-weight="bold">Hoàn tất Cuộc thi</text>
    </g>
  </svg>"""
    return get_html_wrapper(svg, "Hình 4. Sơ đồ Hoạt động (Activity Diagram) thể hiện 2 luồng nghiệp vụ cốt lõi của hệ thống", 1440, 980)


# ==============================================================================
# 5. SƠ ĐỒ ERD Ý NIỆM (CONCEPTUAL ERD - CHEN EXTENDED)
# ==============================================================================
def generate_conceptual_erd_svg():
    w, h = 1480, 1020
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    
    <!-- TOP ROW: HANG_MUC, CUOC_THI, DANG_KY, NGUOI_DUNG, VAI_TRO -->
    <!-- 1. HANG_MUC -->
    <g transform="translate(80, 75)">
      <rect x="0" y="0" width="135" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="135" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="67" y="20" text-anchor="middle" font-size="12" font-weight="bold">HANG_MUC</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK category_id</text>
      <text x="10" y="65" font-size="11">name</text>
      <text x="10" y="85" font-size="11">description</text>
    </g>
    <!-- Attribute Ovals for HANG_MUC -->
    <ellipse cx="40" cy="50" rx="34" ry="14" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
    <text x="40" y="54" text-anchor="middle" font-size="10">category_id</text>
    <line x1="68" y1="58" x2="80" y2="85" stroke="#000000" stroke-width="1"/>

    <ellipse cx="40" cy="115" rx="28" ry="14" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
    <text x="40" y="119" text-anchor="middle" font-size="10">name</text>
    <line x1="68" y1="115" x2="80" y2="120" stroke="#000000" stroke-width="1"/>

    <!-- Relationship: Thuộc (HANG_MUC - CUOC_THI) -->
    <polygon points="265,105 305,122 265,140 225,122" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="265" y="126" text-anchor="middle" font-size="11" font-weight="600">Thuộc</text>
    <line x1="215" y1="122" x2="225" y2="122" stroke="#000000" stroke-width="1.2"/>
    <text x="218" y="115" font-size="11">N</text>
    <text x="216" y="137" font-size="10">(1,1)</text>
    <line x1="305" y1="122" x2="345" y2="122" stroke="#000000" stroke-width="1.2"/>
    <text x="330" y="115" font-size="11">1</text>
    <text x="315" y="137" font-size="10">(1,N)</text>

    <!-- 2. CUOC_THI -->
    <g transform="translate(345, 75)">
      <rect x="0" y="0" width="145" height="110" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="145" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="72" y="20" text-anchor="middle" font-size="12" font-weight="bold">CUOC_THI</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK contest_id</text>
      <text x="10" y="65" font-size="11">title</text>
      <text x="10" y="85" font-size="11">start_date</text>
      <text x="10" y="103" font-size="11">status</text>
    </g>

    <!-- Relationship: Nhận (CUOC_THI - DANG_KY) -->
    <polygon points="545,112 585,130 545,148 505,130" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="545" y="134" text-anchor="middle" font-size="11" font-weight="600">Nhận</text>
    <line x1="490" y1="130" x2="505" y2="130" stroke="#000000" stroke-width="1.2"/>
    <text x="492" y="123" font-size="11">1</text>
    <text x="490" y="145" font-size="10">(0,N)</text>
    <line x1="585" y1="130" x2="625" y2="130" stroke="#000000" stroke-width="1.2"/>
    <text x="610" y="123" font-size="11">N</text>
    <text x="595" y="145" font-size="10">(1,1)</text>

    <!-- 3. DANG_KY -->
    <g transform="translate(625, 75)">
      <rect x="0" y="0" width="150" height="110" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="150" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="75" y="20" text-anchor="middle" font-size="12" font-weight="bold">DANG_KY</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK registration_id</text>
      <text x="10" y="65" font-size="11">registered_at</text>
      <text x="10" y="85" font-size="11">reg_status</text>
      <text x="10" y="103" font-size="11">contest_id (FK)</text>
    </g>

    <!-- Relationship: Lập (NGUOI_DUNG - DANG_KY) -->
    <polygon points="830,112 870,130 830,148 790,130" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="830" y="134" text-anchor="middle" font-size="11" font-weight="600">Lập</text>
    <line x1="775" y1="130" x2="790" y2="130" stroke="#000000" stroke-width="1.2"/>
    <text x="778" y="123" font-size="11">N</text>
    <text x="776" y="145" font-size="10">(1,1)</text>
    <line x1="870" y1="130" x2="910" y2="130" stroke="#000000" stroke-width="1.2"/>
    <text x="895" y="123" font-size="11">1</text>
    <text x="880" y="145" font-size="10">(0,N)</text>

    <!-- 4. NGUOI_DUNG -->
    <g transform="translate(910, 75)">
      <rect x="0" y="0" width="150" height="115" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="150" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="75" y="20" text-anchor="middle" font-size="12" font-weight="bold">NGUOI_DUNG</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK user_id</text>
      <text x="10" y="65" font-size="11">username</text>
      <text x="10" y="85" font-size="11">email</text>
      <text x="10" y="105" font-size="11">full_name</text>
    </g>

    <!-- Relationship: Có (NGUOI_DUNG - VAI_TRO via USER_ROLE) -->
    <polygon points="1120,112 1160,130 1120,148 1080,130" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="1120" y="134" text-anchor="middle" font-size="11" font-weight="600">Có</text>
    <line x1="1060" y1="130" x2="1080" y2="130" stroke="#000000" stroke-width="1.2"/>
    <text x="1065" y="123" font-size="11">M</text>
    <line x1="1160" y1="130" x2="1200" y2="130" stroke="#000000" stroke-width="1.2"/>
    <text x="1185" y="123" font-size="11">N</text>

    <!-- 5. VAI_TRO -->
    <g transform="translate(1200, 75)">
      <rect x="0" y="0" width="135" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="135" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="67" y="20" text-anchor="middle" font-size="12" font-weight="bold">VAI_TRO</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK role_id</text>
      <text x="10" y="65" font-size="11">role_code</text>
      <text x="10" y="85" font-size="11">role_name</text>
    </g>

    <!-- Associative Entity: USER_ROLE -->
    <line x1="1120" y1="148" x2="1120" y2="195" stroke="#000000" stroke-width="1.2" stroke-dasharray="4,3"/>
    <g transform="translate(1045, 195)">
      <rect x="0" y="0" width="150" height="60" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <line x1="0" y1="22" x2="150" y2="22" stroke="#000000" stroke-width="1"/>
      <text x="75" y="16" text-anchor="middle" font-size="10.5" font-weight="bold">USER_ROLE</text>
      <text x="10" y="38" font-size="10" font-weight="bold">PK (user_id, role_id)</text>
      <text x="10" y="52" font-size="10">assigned_at</text>
    </g>

    <!-- Specialization of User: PARTICIPANT_PROFILE -->
    <polygon points="985,190 970,220 1000,220" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <text x="1005" y="210" font-size="9" font-style="italic">&#123;disjoint, optional&#125;</text>
    <text x="1005" y="222" font-size="9" font-style="italic">(Chuyên biệt hóa)</text>
    <line x1="985" y1="220" x2="985" y2="245" stroke="#000000" stroke-width="1.2"/>
    <line x1="985" y1="245" x2="920" y2="245" stroke="#000000" stroke-width="1.2"/>
    <line x1="920" y1="245" x2="920" y2="265" stroke="#000000" stroke-width="1.2"/>

    <g transform="translate(840, 265)">
      <rect x="0" y="0" width="160" height="85" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <line x1="0" y1="24" x2="160" y2="24" stroke="#000000" stroke-width="1"/>
      <text x="80" y="17" text-anchor="middle" font-size="11" font-weight="bold">HO_SO_THI_SINH</text>
      <text x="10" y="42" font-size="10.5" font-weight="bold">PK, FK user_id</text>
      <text x="10" y="58" font-size="10">portfolio_url</text>
      <text x="10" y="74" font-size="10">experience_level</text>
    </g>


    <!-- MIDDLE SECTION: CUON_PHIM, KHUNG_HINH, BAI_THI, THAM_DINH -->
    <!-- 6. CUON_PHIM -->
    <g transform="translate(80, 420)">
      <rect x="0" y="0" width="145" height="110" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="145" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="72" y="20" text-anchor="middle" font-size="12" font-weight="bold">CUON_PHIM</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK roll_id</text>
      <text x="10" y="65" font-size="11">user_id (FK)</text>
      <text x="10" y="85" font-size="11">film_stock_id (FK)</text>
      <text x="10" y="103" font-size="11">iso_used / lab_id</text>
    </g>

    <!-- User to FilmRoll Link -->
    <path d="M 910 165 L 810 165 L 810 380 L 150 380 L 150 420" fill="none" stroke="#000000" stroke-width="1.2"/>
    <polygon points="490,365 525,380 490,395 455,380" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="490" y="384" text-anchor="middle" font-size="11" font-weight="600">Sở hữu</text>
    <text x="815" y="180" font-size="11">1 (1,N)</text>
    <text x="155" y="410" font-size="11">N (1,1)</text>

    <!-- Identifying Relationship: Chứa (CUON_PHIM - KHUNG_HINH) -->
    <polygon points="280,457 320,475 280,493 240,475" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
    <polygon points="280,461 313,475 280,489 247,475" fill="#ffffff" stroke="#000000" stroke-width="1"/>
    <text x="280" y="479" text-anchor="middle" font-size="11" font-weight="600">Chứa</text>
    <line x1="225" y1="475" x2="240" y2="475" stroke="#000000" stroke-width="1.2"/>
    <text x="228" y="468" font-size="11">1</text>
    <text x="226" y="490" font-size="10">(1,N)</text>
    <line x1="320" y1="475" x2="360" y2="475" stroke="#000000" stroke-width="1.2"/>
    <text x="345" y="468" font-size="11">N</text>
    <text x="330" y="490" font-size="10">(1,1)</text>

    <!-- 7. KHUNG_HINH (Weak Entity) -->
    <g transform="translate(360, 420)">
      <rect x="0" y="0" width="145" height="105" fill="#ffffff" stroke="#000000" stroke-width="1.5" stroke-dasharray="4,2"/>
      <rect x="3" y="3" width="139" height="99" fill="none" stroke="#000000" stroke-width="1"/>
      <line x1="0" y1="28" x2="145" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="72" y="20" text-anchor="middle" font-size="12" font-weight="bold">KHUNG_HINH</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK frame_id</text>
      <text x="10" y="65" font-size="11">roll_id (FK)</text>
      <text x="10" y="85" font-size="11">frame_number</text>
      <text x="10" y="100" font-size="11">scan_image_uri</text>
    </g>

    <!-- Relationship: Dự thi (KHUNG_HINH - BAI_THI) -->
    <polygon points="555,457 595,475 555,493 515,475" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="555" y="479" text-anchor="middle" font-size="11" font-weight="600">Dự thi</text>
    <line x1="505" y1="475" x2="515" y2="475" stroke="#000000" stroke-width="1.2"/>
    <text x="508" y="468" font-size="11">1</text>
    <text x="506" y="490" font-size="10">(0,1)</text>
    <line x1="595" y1="475" x2="635" y2="475" stroke="#000000" stroke-width="1.2"/>
    <text x="620" y="468" font-size="11">1</text>
    <text x="605" y="490" font-size="10">(1,1)</text>

    <!-- 8. BAI_THI -->
    <g transform="translate(635, 415)">
      <rect x="0" y="0" width="165" height="120" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="165" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="82" y="20" text-anchor="middle" font-size="12" font-weight="bold">BAI_THI</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK submission_id</text>
      <text x="10" y="65" font-size="11">registration_id (FK)</text>
      <text x="10" y="85" font-size="11">frame_id (FK, UQ)</text>
      <text x="10" y="105" font-size="11">category_id (FK)</text>
      <text x="10" y="120" font-size="10" fill="#666666">submission_status</text>
    </g>

    <!-- Link: Registration - Submission -->
    <line x1="700" y1="185" x2="700" y2="415" stroke="#000000" stroke-width="1.2"/>
    <polygon points="700,285 730,300 700,315 670,300" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="700" y="304" text-anchor="middle" font-size="11" font-weight="600">Nộp</text>
    <text x="705" y="205" font-size="11">1 (1,N)</text>
    <text x="705" y="405" font-size="11">N (1,1)</text>

    <!-- Relationship: Thẩm định (BAI_THI - THAM_DINH_BAI) -->
    <polygon points="855,457 895,475 855,493 815,475" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="855" y="479" text-anchor="middle" font-size="11" font-weight="600">Thẩm định</text>
    <line x1="800" y1="475" x2="815" y2="475" stroke="#000000" stroke-width="1.2"/>
    <text x="802" y="468" font-size="11">1</text>
    <text x="800" y="490" font-size="10">(1,1)</text>
    <line x1="895" y1="475" x2="930" y2="475" stroke="#000000" stroke-width="1.2"/>
    <text x="915" y="468" font-size="11">1</text>
    <text x="900" y="490" font-size="10">(1,1)</text>

    <!-- 9. THAM_DINH_BAI -->
    <g transform="translate(930, 420)">
      <rect x="0" y="0" width="165" height="110" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="165" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="82" y="20" text-anchor="middle" font-size="12" font-weight="bold">THAM_DINH_BAI</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK case_id</text>
      <text x="10" y="65" font-size="11">submission_id (FK)</text>
      <text x="10" y="85" font-size="11">verified_by (FK)</text>
      <text x="10" y="103" font-size="11">decision (Status)</text>
    </g>

    <!-- Relationship: Tư vấn AI (BAI_THI - PHAN_TICH_AI) -->
    <path d="M 720 535 L 720 590 L 920 590" fill="none" stroke="#000000" stroke-width="1.2"/>
    <polygon points="850,575 885,590 850,605 815,590" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="850" y="594" text-anchor="middle" font-size="10.5" font-weight="600">Tư vấn AI</text>
    <line x1="885" y1="590" x2="920" y2="590" stroke="#000000" stroke-width="1.2"/>

    <!-- 10. PHAN_TICH_AI -->
    <g transform="translate(920, 560)">
      <rect x="0" y="0" width="185" height="100" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <line x1="0" y1="24" x2="185" y2="24" stroke="#000000" stroke-width="1"/>
      <text x="92" y="17" text-anchor="middle" font-size="11" font-weight="bold">PHAN_TICH_AI (Advisory)</text>
      <text x="10" y="42" font-size="10.5" font-weight="bold">PK ai_result_id</text>
      <text x="10" y="60" font-size="10.5">submission_id (FK)</text>
      <text x="10" y="78" font-size="10.5">similarity_score / is_flagged</text>
      <text x="10" y="94" font-size="10">synthetic_confidence</text>
    </g>


    <!-- BOTTOM SECTION: CHAM_THI, DIEM_CHI_TIET, GIAI_THUONG, DI_SAN -->
    <!-- 11. VONG_CHAM -->
    <g transform="translate(80, 680)">
      <rect x="0" y="0" width="145" height="105" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="145" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="72" y="20" text-anchor="middle" font-size="12" font-weight="bold">VONG_CHAM</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK round_id</text>
      <text x="10" y="65" font-size="11">contest_id (FK)</text>
      <text x="10" y="85" font-size="11">round_name</text>
      <text x="10" y="100" font-size="11">round_order</text>
    </g>

    <!-- Relationship: Đánh giá (VONG_CHAM - BAI_THI via PHIEU_DANH_GIA) -->
    <line x1="225" y1="730" x2="350" y2="730" stroke="#000000" stroke-width="1.2"/>
    <polygon points="285,715 320,730 285,745 250,730" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="285" y="734" text-anchor="middle" font-size="11" font-weight="600">Đánh giá</text>

    <!-- 12. PHIEU_DANH_GIA -->
    <g transform="translate(350, 680)">
      <rect x="0" y="0" width="165" height="110" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="165" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="82" y="20" text-anchor="middle" font-size="12" font-weight="bold">PHIEU_DANH_GIA</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK evaluation_id</text>
      <text x="10" y="65" font-size="11">submission_id (FK)</text>
      <text x="10" y="85" font-size="11">judge_user_id (FK)</text>
      <text x="10" y="103" font-size="11">round_id (FK)</text>
    </g>

    <!-- Link: Submission - Evaluation -->
    <path d="M 680 535 L 680 650 L 430 650 L 430 680" fill="none" stroke="#000000" stroke-width="1.2"/>
    <text x="685" y="560" font-size="11">1 (1,N)</text>
    <text x="435" y="675" font-size="11">N (1,1)</text>

    <!-- Associative / Detail: DIEM_TIEU_CHI -->
    <polygon points="565,715 600,730 565,745 530,730" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="565" y="734" text-anchor="middle" font-size="10.5" font-weight="600">Chi tiết</text>
    <line x1="515" y1="730" x2="530" y2="730" stroke="#000000" stroke-width="1.2"/>
    <line x1="600" y1="730" x2="635" y2="730" stroke="#000000" stroke-width="1.2"/>

    <g transform="translate(635, 680)">
      <rect x="0" y="0" width="165" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.4" stroke-dasharray="4,2"/>
      <rect x="3" y="3" width="159" height="89" fill="none" stroke="#000000" stroke-width="1"/>
      <line x1="0" y1="24" x2="165" y2="24" stroke="#000000" stroke-width="1"/>
      <text x="82" y="17" text-anchor="middle" font-size="11" font-weight="bold">DIEM_TIEU_CHI</text>
      <text x="10" y="42" font-size="10.5" font-weight="bold">PK (eval_id, criterion_id)</text>
      <text x="10" y="60" font-size="10.5">score [0 - 100]</text>
      <text x="10" y="78" font-size="10.5">criterion_id (FK)</text>
    </g>

    <!-- 13. KET_QUA_CHUNG_CUOC -->
    <path d="M 800 500 L 1150 500 L 1150 680" fill="none" stroke="#000000" stroke-width="1.2"/>
    <polygon points="1150,565 1185,580 1150,595 1115,580" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="1150" y="584" text-anchor="middle" font-size="11" font-weight="600">Xếp hạng</text>

    <g transform="translate(1060, 680)">
      <rect x="0" y="0" width="180" height="105" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="28" x2="180" y2="28" stroke="#000000" stroke-width="1.2"/>
      <text x="90" y="20" text-anchor="middle" font-size="12" font-weight="bold">KET_QUA_CHUNG_CUOC</text>
      <text x="10" y="46" font-size="11" font-weight="bold">PK result_id</text>
      <text x="10" y="65" font-size="11">submission_id (FK)</text>
      <text x="10" y="85" font-size="11">final_score (DECIMAL)</text>
      <text x="10" y="100" font-size="11">rank_position</text>
    </g>

    <!-- Archive Item Link & Entity -->
    <line x1="1150" y1="785" x2="1150" y2="865" stroke="#000000" stroke-width="1.2"/>
    <polygon points="1150,810 1180,825 1150,840 1120,825" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
    <text x="1150" y="829" text-anchor="middle" font-size="10.5" font-weight="600">Snapshot</text>

    <g transform="translate(1045, 865)">
      <rect x="0" y="0" width="210" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="24" x2="210" y2="24" stroke="#000000" stroke-width="1"/>
      <text x="105" y="17" text-anchor="middle" font-size="11" font-weight="bold">DI_SAN_SO (Archive Snapshot)</text>
      <text x="10" y="42" font-size="10.5" font-weight="bold">PK archive_item_id</text>
      <text x="10" y="60" font-size="10.5">submission_id (FK)</text>
      <text x="10" y="78" font-size="10.5">snapshot_title / metadata_json</text>
      <text x="10" y="92" font-size="9.5" font-style="italic" fill="#cc0000">Immutable / Restricted Delete</text>
    </g>

    <!-- SYSTEM CATALOGS (Left Bottom Box) -->
    <g transform="translate(80, 845)">
      <rect x="0" y="0" width="435" height="115" rx="4" fill="#fafafa" stroke="#888888" stroke-width="1.2" stroke-dasharray="3,3"/>
      <text x="15" y="20" font-size="11" font-weight="bold" fill="#003366">DANH MỤC THAM CHIẾU (SYSTEM CATALOGS):</text>
      <text x="15" y="42" font-size="10.5">• <tspan font-weight="bold">DONG_PHIM (FilmStock)</tspan>: film_stock_id, brand, name, iso, format</text>
      <text x="15" y="62" font-size="10.5">• <tspan font-weight="bold">MAY_ANH (Camera)</tspan>: camera_id, brand, model, camera_type</text>
      <text x="15" y="82" font-size="10.5">• <tspan font-weight="bold">ONG_KINH (Lens)</tspan>: lens_id, brand, focal_length, max_aperture</text>
      <text x="15" y="102" font-size="10.5">• <tspan font-weight="bold">PHONG_LAB (Lab)</tspan>: lab_id, name, address, contact_info</text>
    </g>

    <!-- AUDIT LOG (Center Bottom Box) -->
    <g transform="translate(545, 845)">
      <rect x="0" y="0" width="475" height="115" rx="4" fill="#fafafa" stroke="#888888" stroke-width="1.2" stroke-dasharray="3,3"/>
      <text x="15" y="20" font-size="11" font-weight="bold" fill="#003366">NHẬT KÝ KIỂM TOÁN (AUDIT LOGGING):</text>
      <text x="15" y="42" font-size="10.5">• <tspan font-weight="bold">NHAT_KY_KIEM_TOAN (AuditLog)</tspan>: log_id, event_type, table_name, record_id</text>
      <text x="15" y="62" font-size="10.5">• <tspan font-weight="bold">actor_user_id</tspan>: Khóa ngoại liên kết với UserAccount (Người thực hiện)</text>
      <text x="15" y="82" font-size="10.5">• <tspan font-weight="bold">old_values / new_values</tspan>: Dữ liệu JSON trước và sau biến động</text>
      <text x="15" y="102" font-size="10" font-style="italic" fill="#555555">Append-only audit trail ghi vết tự động qua Triggers &amp; Stored Procedures</text>
    </g>
  </svg>"""
    return get_html_wrapper(svg, "Hình 5. Sơ đồ ERD Ý niệm (Conceptual ERD) theo mô hình Chen mở rộng", 1520, 1060)


# ==============================================================================
# 6. SƠ ĐỒ MÔ HÌNH QUAN HỆ / ERD LOGIC (UML CLASS STYLE)
# ==============================================================================
def generate_logical_schema_svg():
    w, h = 1480, 1020
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    <defs>
      <marker id="uml-inherit" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto">
        <polygon points="0,0 10,5 0,10" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      </marker>
    </defs>

    <!-- ROW 1: CATEGORY, CONTEST, REGISTRATION, USER, ROLE -->
    <!-- 1. ContestCategory -->
    <g transform="translate(45, 55)">
      <rect x="0" y="0" width="165" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="165" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="82" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">CONTEST_CATEGORY</text>
      <text x="10" y="44" font-size="10.5">+ category_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ name : NVARCHAR(100)</text>
      <text x="10" y="80" font-size="10.5">+ description : NVARCHAR(500)</text>
    </g>

    <!-- Line: ContestCategory to Contest -->
    <line x1="210" y1="102" x2="285" y2="102" stroke="#000000" stroke-width="1.2"/>
    <text x="215" y="94" font-size="10">0..*</text>
    <text x="238" y="94" font-size="10" font-style="italic">thuộc</text>
    <text x="272" y="94" font-size="10">1</text>

    <!-- 2. Contest -->
    <g transform="translate(285, 45)">
      <rect x="0" y="0" width="180" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="180" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="90" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">CONTEST</text>
      <text x="10" y="44" font-size="10.5">+ contest_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ title : NVARCHAR(200)</text>
      <text x="10" y="80" font-size="10.5">+ start_date : DATE</text>
      <text x="10" y="98" font-size="10.5">+ end_date : DATE</text>
      <text x="10" y="116" font-size="10.5">+ status : NVARCHAR(30)</text>
    </g>

    <!-- Line: Contest to Registration -->
    <line x1="465" y1="102" x2="540" y2="102" stroke="#000000" stroke-width="1.2"/>
    <text x="470" y="94" font-size="10">1</text>
    <text x="495" y="94" font-size="10" font-style="italic">nhận</text>
    <text x="522" y="94" font-size="10">0..*</text>

    <!-- 3. Registration -->
    <g transform="translate(540, 45)">
      <rect x="0" y="0" width="180" height="130" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="180" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="90" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">REGISTRATION</text>
      <text x="10" y="44" font-size="10.5">+ registration_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ contest_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ user_id : INT [FK]</text>
      <text x="10" y="98" font-size="10.5">+ registered_at : DATETIME2</text>
      <text x="10" y="116" font-size="10.5">+ reg_status : NVARCHAR(30)</text>
    </g>

    <!-- Line: Registration to UserAccount -->
    <line x1="720" y1="102" x2="795" y2="102" stroke="#000000" stroke-width="1.2"/>
    <text x="725" y="94" font-size="10">0..*</text>
    <text x="748" y="94" font-size="10" font-style="italic">lập bởi</text>
    <text x="780" y="94" font-size="10">1</text>

    <!-- 4. UserAccount -->
    <g transform="translate(795, 45)">
      <rect x="0" y="0" width="190" height="145" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="190" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="95" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">USER_ACCOUNT</text>
      <text x="10" y="44" font-size="10.5">+ user_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ username : NVARCHAR(50)</text>
      <text x="10" y="80" font-size="10.5">+ email : VARCHAR(100)</text>
      <text x="10" y="98" font-size="10.5">+ full_name : NVARCHAR(100)</text>
      <text x="10" y="116" font-size="10.5">+ is_active : BIT</text>
      <text x="10" y="134" font-size="10.5">+ created_at : DATETIME2</text>
    </g>

    <!-- Line: User to Role via UserRole -->
    <line x1="985" y1="102" x2="1200" y2="102" stroke="#000000" stroke-width="1.2"/>
    <text x="990" y="94" font-size="10">1..*</text>
    <text x="1075" y="94" font-size="10" font-style="italic">phân quyền</text>
    <text x="1180" y="94" font-size="10">1..*</text>

    <!-- 5. Role -->
    <g transform="translate(1200, 55)">
      <rect x="0" y="0" width="160" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="160" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="80" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">ROLE</text>
      <text x="10" y="44" font-size="10.5">+ role_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ role_code : VARCHAR(30)</text>
      <text x="10" y="80" font-size="10.5">+ role_name : NVARCHAR(100)</text>
    </g>

    <!-- Associative Class: USER_ROLE -->
    <line x1="1090" y1="102" x2="1090" y2="155" stroke="#000000" stroke-width="1.2" stroke-dasharray="4,3"/>
    <g transform="translate(1015, 155)">
      <rect x="0" y="0" width="155" height="65" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <line x1="0" y1="22" x2="155" y2="22" stroke="#000000" stroke-width="1"/>
      <text x="77" y="16" text-anchor="middle" font-size="10.5" font-weight="bold">USER_ROLE</text>
      <text x="10" y="38" font-size="10">+ user_id : INT [FK]</text>
      <text x="10" y="54" font-size="10">+ role_id : INT [FK]</text>
    </g>

    <!-- Generalization / Inheritance: ParticipantProfile -->
    <line x1="890" y1="190" x2="890" y2="260" stroke="#000000" stroke-width="1.4" marker-start="url(#uml-inherit)"/>
    <g transform="translate(805, 260)">
      <rect x="0" y="0" width="180" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <line x1="0" y1="24" x2="180" y2="24" stroke="#000000" stroke-width="1"/>
      <text x="90" y="17" text-anchor="middle" font-size="11" font-weight="bold">PARTICIPANT_PROFILE</text>
      <text x="10" y="42" font-size="10.5">+ user_id : INT [PK, FK]</text>
      <text x="10" y="60" font-size="10.5">+ portfolio_url : NVARCHAR(255)</text>
      <text x="10" y="78" font-size="10.5">+ experience_level : NVARCHAR(50)</text>
    </g>


    <!-- ROW 2: FILM ASSET, SUBMISSION, VERIFICATION, AI -->
    <!-- 6. FilmRoll -->
    <g transform="translate(45, 420)">
      <rect x="0" y="0" width="175" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="175" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="87" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">FILM_ROLL</text>
      <text x="10" y="44" font-size="10.5">+ roll_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ user_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ film_stock_id : INT [FK]</text>
      <text x="10" y="98" font-size="10.5">+ iso_used : INT</text>
      <text x="10" y="116" font-size="10.5">+ lab_id : INT [FK]</text>
    </g>

    <!-- User to FilmRoll Link -->
    <path d="M 830 190 L 830 380 L 130 380 L 130 420" fill="none" stroke="#000000" stroke-width="1.2"/>
    <text x="835" y="210" font-size="10">1</text>
    <text x="440" y="375" font-size="10" font-style="italic">sở hữu</text>
    <text x="135" y="415" font-size="10">0..*</text>

    <!-- FilmRoll to FilmFrame -->
    <line x1="220" y1="480" x2="285" y2="480" stroke="#000000" stroke-width="1.2"/>
    <text x="225" y="473" font-size="10">1</text>
    <text x="245" y="473" font-size="10" font-style="italic">chứa</text>
    <text x="268" y="473" font-size="10">1..*</text>

    <!-- 7. FilmFrame (Weak Entity with dashed border) -->
    <g transform="translate(285, 420)">
      <rect x="0" y="0" width="180" height="125" fill="#ffffff" stroke="#000000" stroke-width="1.5" stroke-dasharray="4,2"/>
      <line x1="0" y1="26" x2="180" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="90" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">FILM_FRAME</text>
      <text x="10" y="44" font-size="10.5">+ frame_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ roll_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ frame_number : INT</text>
      <text x="10" y="98" font-size="10.5">+ scan_image_uri : NVARCHAR(500)</text>
      <text x="10" y="116" font-size="9.5" font-style="italic" fill="#555555">(Thực thể yếu)</text>
    </g>

    <!-- FilmFrame to Submission -->
    <line x1="465" y1="480" x2="540" y2="480" stroke="#000000" stroke-width="1.2"/>
    <text x="470" y="473" font-size="10">1</text>
    <text x="495" y="473" font-size="10" font-style="italic">dự thi</text>
    <text x="522" y="473" font-size="10">0..1</text>

    <!-- 8. Submission -->
    <g transform="translate(540, 400)">
      <rect x="0" y="0" width="215" height="175" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="215" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="107" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">SUBMISSION</text>
      <text x="10" y="44" font-size="10.5">+ submission_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ registration_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ frame_id : INT [FK, UQ]</text>
      <text x="10" y="98" font-size="10.5">+ category_id : INT [FK]</text>
      <text x="10" y="116" font-size="10.5">+ title : NVARCHAR(200)</text>
      <text x="10" y="134" font-size="10.5">+ submission_status : NVARCHAR(30)</text>
      <text x="10" y="152" font-size="10.5">+ submitted_at : DATETIME2</text>
      <text x="10" y="168" font-size="9.5" fill="#0066cc">UQ(contest_id, frame_id)</text>
    </g>

    <!-- Line: Registration to Submission -->
    <line x1="630" y1="175" x2="630" y2="400" stroke="#000000" stroke-width="1.2"/>
    <text x="635" y="195" font-size="10">1</text>
    <text x="635" y="285" font-size="10" font-style="italic">chứa</text>
    <text x="635" y="390" font-size="10">0..*</text>

    <!-- Submission to VerificationCase -->
    <line x1="755" y1="480" x2="825" y2="480" stroke="#000000" stroke-width="1.2"/>
    <text x="760" y="473" font-size="10">1</text>
    <text x="775" y="473" font-size="10" font-style="italic">thẩm định</text>
    <text x="810" y="473" font-size="10">0..1</text>

    <!-- 9. VerificationCase -->
    <g transform="translate(825, 410)">
      <rect x="0" y="0" width="195" height="145" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="195" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="97" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">VERIFICATION_CASE</text>
      <text x="10" y="44" font-size="10.5">+ case_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ submission_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ verified_by : INT [FK]</text>
      <text x="10" y="98" font-size="10.5">+ decision : NVARCHAR(30)</text>
      <text x="10" y="116" font-size="10.5">+ reason : NVARCHAR(500)</text>
      <text x="10" y="134" font-size="10.5">+ verified_at : DATETIME2</text>
    </g>

    <!-- Submission to AIAnalysisResult -->
    <path d="M 700 575 L 700 615 L 1100 615 L 1100 410" fill="none" stroke="#000000" stroke-width="1.2"/>
    <text x="710" y="590" font-size="10">1</text>
    <text x="890" y="610" font-size="10" font-style="italic">tư vấn AI</text>
    <text x="1105" y="405" font-size="10">0..*</text>

    <!-- 10. AIAnalysisResult -->
    <g transform="translate(1100, 410)">
      <rect x="0" y="0" width="205" height="145" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="205" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="102" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">AI_ANALYSIS_RESULT</text>
      <text x="10" y="44" font-size="10.5">+ ai_result_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ submission_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ similarity_score : DECIMAL(5,2)</text>
      <text x="10" y="98" font-size="10.5">+ is_flagged : BIT</text>
      <text x="10" y="116" font-size="10.5">+ synthetic_confidence : DECIMAL(5,2)</text>
      <text x="10" y="134" font-size="10.5">+ analyzed_at : DATETIME2</text>
    </g>


    <!-- ROW 3: JUDGING, EVALUATION, SCORES, RESULT, ARCHIVE -->
    <!-- 11. JudgingRound -->
    <g transform="translate(45, 700)">
      <rect x="0" y="0" width="175" height="125" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="175" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="87" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">JUDGING_ROUND</text>
      <text x="10" y="44" font-size="10.5">+ round_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ contest_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ round_name : NVARCHAR(100)</text>
      <text x="10" y="98" font-size="10.5">+ round_order : INT</text>
      <text x="10" y="116" font-size="10.5">+ status : NVARCHAR(30)</text>
    </g>

    <!-- JudgingRound to Evaluation -->
    <line x1="220" y1="760" x2="285" y2="760" stroke="#000000" stroke-width="1.2"/>
    <text x="225" y="753" font-size="10">1</text>
    <text x="245" y="753" font-size="10" font-style="italic">chấm</text>
    <text x="268" y="753" font-size="10">0..*</text>

    <!-- 12. Evaluation -->
    <g transform="translate(285, 690)">
      <rect x="0" y="0" width="195" height="155" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="195" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="97" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">EVALUATION</text>
      <text x="10" y="44" font-size="10.5">+ evaluation_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ submission_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ judge_user_id : INT [FK]</text>
      <text x="10" y="98" font-size="10.5">+ round_id : INT [FK]</text>
      <text x="10" y="116" font-size="10.5">+ total_score : DECIMAL(5,2)</text>
      <text x="10" y="134" font-size="10.5">+ feedback : NVARCHAR(MAX)</text>
      <text x="10" y="150" font-size="10.5">+ eval_status : NVARCHAR(30)</text>
    </g>

    <!-- Submission to Evaluation Line -->
    <path d="M 580 575 L 580 760 L 480 760" fill="none" stroke="#000000" stroke-width="1.2"/>
    <text x="585" y="620" font-size="10">1</text>
    <text x="515" y="753" font-size="10" font-style="italic">nhận đánh giá</text>
    <text x="485" y="753" font-size="10">0..*</text>

    <!-- Evaluation to EvaluationScore -->
    <line x1="480" y1="780" x2="550" y2="780" stroke="#000000" stroke-width="1.2"/>
    <text x="485" y="773" font-size="10">1</text>
    <text x="505" y="773" font-size="10" font-style="italic">chi tiết</text>
    <text x="532" y="773" font-size="10">1..*</text>

    <!-- 13. EvaluationScore (Weak Entity) -->
    <g transform="translate(550, 710)">
      <rect x="0" y="0" width="195" height="120" fill="#ffffff" stroke="#000000" stroke-width="1.5" stroke-dasharray="4,2"/>
      <line x1="0" y1="26" x2="195" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="97" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">EVALUATION_SCORE</text>
      <text x="10" y="44" font-size="10.5">+ score_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ evaluation_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ criterion_id : INT [FK]</text>
      <text x="10" y="98" font-size="10.5">+ score : DECIMAL(5,2)</text>
      <text x="10" y="114" font-size="9.5" font-style="italic" fill="#555555">CHECK(score BETWEEN 0 AND 100)</text>
    </g>

    <!-- 14. Result -->
    <g transform="translate(810, 700)">
      <rect x="0" y="0" width="195" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="195" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="97" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">RESULT</text>
      <text x="10" y="44" font-size="10.5">+ result_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ submission_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ final_score : DECIMAL(5,2)</text>
      <text x="10" y="98" font-size="10.5">+ rank_position : INT</text>
      <text x="10" y="116" font-size="10.5">+ is_published : BIT</text>
      <text x="10" y="130" font-size="9.5" fill="#0066cc">UQ(submission_id)</text>
    </g>

    <!-- Submission to Result -->
    <path d="M 660 575 L 660 650 L 905 650 L 905 700" fill="none" stroke="#000000" stroke-width="1.2"/>
    <text x="665" y="590" font-size="10">1</text>
    <text x="770" y="645" font-size="10" font-style="italic">xếp hạng</text>
    <text x="910" y="695" font-size="10">0..1</text>

    <!-- Result to ArchiveItem -->
    <line x1="1005" y1="760" x2="1085" y2="760" stroke="#000000" stroke-width="1.2"/>
    <text x="1010" y="753" font-size="10">1</text>
    <text x="1030" y="753" font-size="10" font-style="italic">snapshot</text>
    <text x="1070" y="753" font-size="10">0..1</text>

    <!-- 15. ArchiveItem -->
    <g transform="translate(1085, 690)">
      <rect x="0" y="0" width="220" height="155" fill="#ffffff" stroke="#000000" stroke-width="1.5"/>
      <line x1="0" y1="26" x2="220" y2="26" stroke="#000000" stroke-width="1.2"/>
      <text x="110" y="18" text-anchor="middle" font-size="11.5" font-weight="bold">ARCHIVE_ITEM</text>
      <text x="10" y="44" font-size="10.5">+ archive_item_id : INT</text>
      <text x="10" y="62" font-size="10.5">+ submission_id : INT [FK]</text>
      <text x="10" y="80" font-size="10.5">+ snapshot_title : NVARCHAR(200)</text>
      <text x="10" y="98" font-size="10.5">+ snapshot_metadata : NVARCHAR(MAX)</text>
      <text x="10" y="116" font-size="10.5">+ archived_at : DATETIME2</text>
      <text x="10" y="134" font-size="9.5" fill="#cc0000">ON DELETE RESTRICT</text>
      <text x="10" y="148" font-size="9.5" font-style="italic" fill="#555555">(Bản chụp di sản số bất biến)</text>
    </g>

    <!-- FOOTNOTE / 3NF NOTE -->
    <g transform="translate(45, 890)">
      <rect x="0" y="0" width="1390" height="70" rx="4" fill="#fafafa" stroke="#999999" stroke-width="1"/>
      <text x="15" y="22" font-size="11" font-weight="bold" fill="#000000">GHI CHÚ CHUẨN HÓA MÔ HÌNH QUAN HỆ (3NF LOGICAL NORMALIZATION):</text>
      <text x="15" y="42" font-size="10.5" fill="#333333">1. Tất cả quan hệ N:M (User-Role, Round-Judge, Evaluation-Criterion, Result-Award) đều được chuẩn hóa thành các bảng kết hợp độc lập có khóa ngoại kép.</text>
      <text x="15" y="60" font-size="10.5" fill="#333333">2. Loại bỏ triệt để phụ thuộc hàm từng phần (2NF) và phụ thuộc bắc cầu (3NF); siêu dữ liệu phim, hồ sơ thí sinh, audit log và di sản số đều có bảng quản trị riêng biệt.</text>
    </g>
  </svg>"""
    return get_html_wrapper(svg, "Hình 6. Sơ đồ Lớp UML / ERD Logic thể hiện cấu trúc bảng chuẩn hóa 3NF và quan hệ thực thể", 1520, 1060)


# ==============================================================================
# 7. SƠ ĐỒ VẬT LÝ CƠ SỞ DỮ LIỆU (PHYSICAL DATABASE DIAGRAM - PDM)
# ==============================================================================
def generate_physical_pdm_svg():
    w, h = 1480, 1040
    svg = f"""<svg width="{w}" height="{h}" viewBox="0 0 {w} {h}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Segoe UI', Arial, sans-serif;">
    
    <!-- Outer Group Headers -->
    <text x="50" y="35" font-size="15" font-weight="bold" fill="#000000">SƠ ĐỒ VẬT LÝ CƠ SỞ DỮ LIỆU MICROSOFT SQL SERVER 2022 (FilmContestDB - 24 TABLES)</text>

    <!-- SUBSYSTEM 1: IAM & PROFILES (Top Left) -->
    <rect x="40" y="55" width="440" height="280" rx="4" fill="#fafafa" stroke="#333333" stroke-width="1.2"/>
    <text x="55" y="75" font-size="11.5" font-weight="bold" fill="#003366">PHÂN HỆ 1: IDENTITY &amp; ACCESS (iam)</text>

    <!-- Table: iam.UserAccount -->
    <g transform="translate(55, 90)">
      <rect x="0" y="0" width="190" height="140" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.UserAccount</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] user_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ username : NVARCHAR(50) NOT NULL</text>
      <text x="8" y="70" font-size="9">+ email : VARCHAR(100) NOT NULL UQ</text>
      <text x="8" y="86" font-size="9">+ password_hash : VARCHAR(255)</text>
      <text x="8" y="102" font-size="9">+ full_name : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="118" font-size="9">+ is_active : BIT NOT NULL DEFAULT 1</text>
      <text x="8" y="134" font-size="9">+ created_at : DATETIME2(7) NOT NULL</text>
    </g>

    <!-- Table: iam.Role & UserRole -->
    <g transform="translate(265, 90)">
      <rect x="0" y="0" width="190" height="85" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.Role</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] role_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ role_code : VARCHAR(30) NOT NULL UQ</text>
      <text x="8" y="70" font-size="9">+ role_name : NVARCHAR(100) NOT NULL</text>
    </g>

    <g transform="translate(265, 190)">
      <rect x="0" y="0" width="190" height="75" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.UserRole</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK,FK1] user_id : INT</text>
      <text x="8" y="54" font-size="9" font-weight="bold" fill="#cc0000">[PK,FK2] role_id : INT</text>
      <text x="8" y="70" font-size="9">+ assigned_at : DATETIME2(7)</text>
    </g>

    <g transform="translate(55, 245)">
      <rect x="0" y="0" width="190" height="75" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="20" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="14" text-anchor="middle" font-size="9.5" font-weight="bold">dbo.ParticipantProfile</text>
      <text x="8" y="34" font-size="8.5" font-weight="bold" fill="#cc0000">[PK,FK] user_id : INT</text>
      <text x="8" y="48" font-size="8.5">+ portfolio_url : NVARCHAR(255)</text>
      <text x="8" y="62" font-size="8.5">+ experience_level : NVARCHAR(50)</text>
    </g>


    <!-- SUBSYSTEM 2: CONTESTS & REGISTRATION (Top Right) -->
    <rect x="510" y="55" width="450" height="280" rx="4" fill="#fafafa" stroke="#333333" stroke-width="1.2"/>
    <text x="525" y="75" font-size="11.5" font-weight="bold" fill="#003366">PHÂN HỆ 2: CONTEST MANAGEMENT &amp; REGISTRATION</text>

    <!-- Table: dbo.Contest -->
    <g transform="translate(525, 90)">
      <rect x="0" y="0" width="200" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.Contest</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] contest_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ title : NVARCHAR(200) NOT NULL</text>
      <text x="8" y="70" font-size="9">+ start_date : DATE NOT NULL</text>
      <text x="8" y="86" font-size="9">+ end_date : DATE NOT NULL</text>
      <text x="8" y="102" font-size="9">+ status : NVARCHAR(30) NOT NULL</text>
      <text x="8" y="118" font-size="9">+ created_by : INT FK NOT NULL</text>
      <text x="8" y="130" font-size="8" fill="#555555">CK(start_date &lt; end_date)</text>
    </g>

    <!-- Table: dbo.ContestCategory & Registration -->
    <g transform="translate(740, 90)">
      <rect x="0" y="0" width="205" height="90" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="205" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="102" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.ContestCategory</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] category_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ contest_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ name : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="86" font-size="9">+ description : NVARCHAR(500)</text>
    </g>

    <g transform="translate(740, 195)">
      <rect x="0" y="0" width="205" height="125" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="205" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="102" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.Registration</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] registration_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ contest_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ user_id : INT FK NOT NULL</text>
      <text x="8" y="86" font-size="9">+ registered_at : DATETIME2 NOT NULL</text>
      <text x="8" y="102" font-size="9">+ reg_status : NVARCHAR(30) NOT NULL</text>
      <text x="8" y="118" font-size="8.5" fill="#0066cc">UQ(contest_id, user_id)</text>
    </g>


    <!-- SUBSYSTEM 3: CATALOGS & LABS (Top Far Right) -->
    <rect x="990" y="55" width="450" height="280" rx="4" fill="#fafafa" stroke="#333333" stroke-width="1.2"/>
    <text x="1005" y="75" font-size="11.5" font-weight="bold" fill="#003366">PHÂN HỆ 3: DANH MỤC THAM CHIẾU (catalogs)</text>

    <g transform="translate(1005, 90)">
      <rect x="0" y="0" width="200" height="85" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="20" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="14" text-anchor="middle" font-size="9.5" font-weight="bold">dbo.FilmStock</text>
      <text x="8" y="34" font-size="8.5" font-weight="bold" fill="#cc0000">[PK] film_stock_id : INT IDENTITY</text>
      <text x="8" y="48" font-size="8.5">+ brand : NVARCHAR(50) NOT NULL</text>
      <text x="8" y="62" font-size="8.5">+ name : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="76" font-size="8.5">+ nominal_iso : INT NOT NULL</text>
    </g>

    <g transform="translate(1225, 90)">
      <rect x="0" y="0" width="200" height="85" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="20" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="14" text-anchor="middle" font-size="9.5" font-weight="bold">dbo.Lab</text>
      <text x="8" y="34" font-size="8.5" font-weight="bold" fill="#cc0000">[PK] lab_id : INT IDENTITY</text>
      <text x="8" y="48" font-size="8.5">+ name : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="62" font-size="8.5">+ address : NVARCHAR(255)</text>
      <text x="8" y="76" font-size="8.5">+ contact_phone : VARCHAR(30)</text>
    </g>

    <g transform="translate(1005, 190)">
      <rect x="0" y="0" width="200" height="85" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="20" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="14" text-anchor="middle" font-size="9.5" font-weight="bold">dbo.Camera</text>
      <text x="8" y="34" font-size="8.5" font-weight="bold" fill="#cc0000">[PK] camera_id : INT IDENTITY</text>
      <text x="8" y="48" font-size="8.5">+ brand : NVARCHAR(50) NOT NULL</text>
      <text x="8" y="62" font-size="8.5">+ model : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="76" font-size="8.5">+ format : VARCHAR(30)</text>
    </g>

    <g transform="translate(1225, 190)">
      <rect x="0" y="0" width="200" height="85" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="20" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="14" text-anchor="middle" font-size="9.5" font-weight="bold">dbo.Lens</text>
      <text x="8" y="34" font-size="8.5" font-weight="bold" fill="#cc0000">[PK] lens_id : INT IDENTITY</text>
      <text x="8" y="48" font-size="8.5">+ brand : NVARCHAR(50) NOT NULL</text>
      <text x="8" y="62" font-size="8.5">+ focal_length : NVARCHAR(50)</text>
      <text x="8" y="76" font-size="8.5">+ max_aperture : NVARCHAR(20)</text>
    </g>


    <!-- SUBSYSTEM 4: FILM ASSETS & SUBMISSION (Middle Row) -->
    <rect x="40" y="360" width="920" height="285" rx="4" fill="#fafafa" stroke="#333333" stroke-width="1.2"/>
    <text x="55" y="380" font-size="11.5" font-weight="bold" fill="#003366">PHÂN HỆ 4: TÀI SẢN PHIM (film), BÀI THI (submission) &amp; THẨM ĐỊNH AI</text>

    <!-- Table: dbo.FilmRoll -->
    <g transform="translate(55, 395)">
      <rect x="0" y="0" width="190" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.FilmRoll</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] roll_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ user_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ film_stock_id : INT FK NOT NULL</text>
      <text x="8" y="86" font-size="9">+ iso_used : INT NOT NULL</text>
      <text x="8" y="102" font-size="9">+ camera_id : INT FK</text>
      <text x="8" y="118" font-size="9">+ lab_id : INT FK NOT NULL</text>
      <text x="8" y="132" font-size="8.5" fill="#555555">CK(iso_used &gt; 0)</text>
    </g>

    <!-- Table: dbo.FilmFrame -->
    <g transform="translate(265, 395)">
      <rect x="0" y="0" width="190" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.FilmFrame</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] frame_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ roll_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ frame_number : INT NOT NULL</text>
      <text x="8" y="86" font-size="9">+ scan_image_uri : NVARCHAR(500)</text>
      <text x="8" y="102" font-size="9">+ exposure_notes : NVARCHAR(255)</text>
      <text x="8" y="118" font-size="8.5" fill="#0066cc">UQ(roll_id, frame_number)</text>
      <text x="8" y="130" font-size="8" fill="#555555">CK(frame_number &gt; 0)</text>
    </g>

    <!-- Table: dbo.Submission -->
    <g transform="translate(480, 395)">
      <rect x="0" y="0" width="225" height="160" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <rect x="0" y="0" width="225" height="22" fill="#cbd5e1" stroke="#000000" stroke-width="1"/>
      <text x="112" y="15" text-anchor="middle" font-size="10.5" font-weight="bold">dbo.Submission (CỐT LÕI)</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] submission_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ registration_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ frame_id : INT FK NOT NULL UQ</text>
      <text x="8" y="86" font-size="9">+ category_id : INT FK NOT NULL</text>
      <text x="8" y="102" font-size="9">+ title : NVARCHAR(200) NOT NULL</text>
      <text x="8" y="118" font-size="9">+ description : NVARCHAR(MAX)</text>
      <text x="8" y="134" font-size="9">+ submission_status : NVARCHAR(30)</text>
      <text x="8" y="150" font-size="9">+ submitted_at : DATETIME2 NOT NULL</text>
    </g>

    <!-- Table: dbo.VerificationCase & AIAnalysisResult -->
    <g transform="translate(730, 395)">
      <rect x="0" y="0" width="215" height="115" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="215" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="107" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.VerificationCase</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] case_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ submission_id : INT FK NOT NULL UQ</text>
      <text x="8" y="70" font-size="9">+ verified_by : INT FK NOT NULL</text>
      <text x="8" y="86" font-size="9">+ decision : NVARCHAR(30) NOT NULL</text>
      <text x="8" y="102" font-size="9">+ verified_at : DATETIME2 NOT NULL</text>
    </g>

    <g transform="translate(730, 520)">
      <rect x="0" y="0" width="215" height="115" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="215" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="107" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.AIAnalysisResult</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] ai_result_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ submission_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ similarity_score : DECIMAL(5,2)</text>
      <text x="8" y="86" font-size="9">+ is_flagged : BIT NOT NULL DEFAULT 0</text>
      <text x="8" y="102" font-size="9">+ synthetic_confidence : DECIMAL(5,2)</text>
    </g>


    <!-- SUBSYSTEM 5: JUDGING & SCORING (Bottom Left & Middle) -->
    <rect x="40" y="665" width="920" height="340" rx="4" fill="#fafafa" stroke="#333333" stroke-width="1.2"/>
    <text x="55" y="685" font-size="11.5" font-weight="bold" fill="#003366">PHÂN HỆ 5: HỘI ĐỒNG GIÁM KHẢO, TIÊU CHÍ &amp; CHẤM THI NHIỀU VÒNG (judging)</text>

    <!-- Table: dbo.JudgingRound -->
    <g transform="translate(55, 700)">
      <rect x="0" y="0" width="190" height="115" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.JudgingRound</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] round_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ contest_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ round_name : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="86" font-size="9">+ round_order : INT NOT NULL</text>
      <text x="8" y="102" font-size="9">+ status : NVARCHAR(30) NOT NULL</text>
    </g>

    <!-- Table: dbo.ScoringCriterion -->
    <g transform="translate(55, 830)">
      <rect x="0" y="0" width="190" height="115" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.ScoringCriterion</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] criterion_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ round_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ criterion_name : NVARCHAR(100)</text>
      <text x="8" y="86" font-size="9">+ weight : DECIMAL(5,2) NOT NULL</text>
      <text x="8" y="102" font-size="8.5" fill="#555555">CK(weight &gt; 0 AND weight &lt;= 1)</text>
    </g>

    <!-- Table: dbo.JudgeAssignment -->
    <g transform="translate(265, 700)">
      <rect x="0" y="0" width="190" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="190" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="95" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.JudgeAssignment</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK,FK1] round_id : INT</text>
      <text x="8" y="54" font-size="9" font-weight="bold" fill="#cc0000">[PK,FK2] judge_user_id : INT</text>
      <text x="8" y="70" font-size="9">+ assigned_at : DATETIME2 NOT NULL</text>
      <text x="8" y="86" font-size="9">+ is_head_judge : BIT NOT NULL</text>
    </g>

    <!-- Table: dbo.Evaluation -->
    <g transform="translate(480, 700)">
      <rect x="0" y="0" width="225" height="155" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <rect x="0" y="0" width="225" height="22" fill="#cbd5e1" stroke="#000000" stroke-width="1"/>
      <text x="112" y="15" text-anchor="middle" font-size="10.5" font-weight="bold">dbo.Evaluation</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] evaluation_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ submission_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ judge_user_id : INT FK NOT NULL</text>
      <text x="8" y="86" font-size="9">+ round_id : INT FK NOT NULL</text>
      <text x="8" y="102" font-size="9">+ total_score : DECIMAL(5,2)</text>
      <text x="8" y="118" font-size="9">+ feedback : NVARCHAR(MAX)</text>
      <text x="8" y="134" font-size="9">+ eval_status : NVARCHAR(30) NOT NULL</text>
      <text x="8" y="148" font-size="8.5" fill="#0066cc">UQ(submission_id, judge_user_id, round_id)</text>
    </g>

    <!-- Table: dbo.EvaluationScore -->
    <g transform="translate(730, 700)">
      <rect x="0" y="0" width="215" height="120" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="215" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="107" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.EvaluationScore</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] score_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ evaluation_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ criterion_id : INT FK NOT NULL</text>
      <text x="8" y="86" font-size="9">+ score : DECIMAL(5,2) NOT NULL</text>
      <text x="8" y="102" font-size="8.5" fill="#0066cc">UQ(evaluation_id, criterion_id)</text>
      <text x="8" y="114" font-size="8" fill="#555555">CK(score BETWEEN 0 AND 100)</text>
    </g>


    <!-- SUBSYSTEM 6: RESULT, AWARDS, ARCHIVE & AUDIT (Bottom Right) -->
    <rect x="990" y="360" width="450" height="645" rx="4" fill="#fafafa" stroke="#333333" stroke-width="1.2"/>
    <text x="1005" y="380" font-size="11.5" font-weight="bold" fill="#003366">PHÂN HỆ 6: XẾP HẠNG, GIẢI THƯỞNG, DI SẢN &amp; AUDIT LOG</text>

    <!-- Table: dbo.Result -->
    <g transform="translate(1005, 395)">
      <rect x="0" y="0" width="200" height="120" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.Result</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] result_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ submission_id : INT FK NOT NULL UQ</text>
      <text x="8" y="70" font-size="9">+ final_score : DECIMAL(5,2) NOT NULL</text>
      <text x="8" y="86" font-size="9">+ rank_position : INT NOT NULL</text>
      <text x="8" y="102" font-size="9">+ is_published : BIT NOT NULL DEFAULT 0</text>
    </g>

    <!-- Table: dbo.AwardDefinition & AwardAssignment -->
    <g transform="translate(1225, 395)">
      <rect x="0" y="0" width="200" height="110" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.AwardDefinition</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] award_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ contest_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ award_name : NVARCHAR(100) NOT NULL</text>
      <text x="8" y="86" font-size="9">+ prize_value : DECIMAL(18,2)</text>
      <text x="8" y="102" font-size="9">+ quantity : INT NOT NULL DEFAULT 1</text>
    </g>

    <g transform="translate(1005, 530)">
      <rect x="0" y="0" width="200" height="95" fill="#ffffff" stroke="#000000" stroke-width="1.2"/>
      <rect x="0" y="0" width="200" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="100" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.AwardAssignment</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] assignment_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ award_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ result_id : INT FK NOT NULL UQ</text>
      <text x="8" y="86" font-size="9">+ assigned_at : DATETIME2 NOT NULL</text>
    </g>

    <!-- Table: dbo.ArchiveItem -->
    <g transform="translate(1225, 530)">
      <rect x="0" y="0" width="200" height="135" fill="#ffffff" stroke="#000000" stroke-width="1.4"/>
      <rect x="0" y="0" width="200" height="22" fill="#cbd5e1" stroke="#000000" stroke-width="1"/>
      <text x="100" y="15" text-anchor="middle" font-size="10" font-weight="bold">dbo.ArchiveItem (SNAPSHOT)</text>
      <text x="8" y="38" font-size="9" font-weight="bold" fill="#cc0000">[PK] archive_item_id : INT IDENTITY</text>
      <text x="8" y="54" font-size="9">+ submission_id : INT FK NOT NULL</text>
      <text x="8" y="70" font-size="9">+ snapshot_title : NVARCHAR(200)</text>
      <text x="8" y="86" font-size="9">+ snapshot_metadata : NVARCHAR(MAX)</text>
      <text x="8" y="102" font-size="9">+ archived_at : DATETIME2 NOT NULL</text>
      <text x="8" y="118" font-size="8.5" fill="#cc0000">ON DELETE RESTRICT</text>
      <text x="8" y="130" font-size="8" fill="#555555">(Di sản số bất biến)</text>
    </g>

    <!-- Table: dbo.AuditLog -->
    <g transform="translate(1005, 680)">
      <rect x="0" y="0" width="420" height="150" fill="#ffffff" stroke="#000000" stroke-width="1.3"/>
      <rect x="0" y="0" width="420" height="22" fill="#e2e8f0" stroke="#000000" stroke-width="1"/>
      <text x="210" y="15" text-anchor="middle" font-size="10.5" font-weight="bold">dbo.AuditLog (NHẬT KÝ KIỂM TOÁN HỆ THỐNG)</text>
      <text x="12" y="40" font-size="9.5" font-weight="bold" fill="#cc0000">[PK] log_id : BIGINT IDENTITY</text>
      <text x="12" y="58" font-size="9.5">+ event_type : VARCHAR(50) NOT NULL (INSERT / UPDATE / DELETE / LOGIN / STATE_CHANGE)</text>
      <text x="12" y="76" font-size="9.5">+ table_name : VARCHAR(100) NOT NULL</text>
      <text x="12" y="94" font-size="9.5">+ record_id : VARCHAR(100) NOT NULL</text>
      <text x="12" y="112" font-size="9.5">+ actor_user_id : INT FK NOT NULL</text>
      <text x="12" y="130" font-size="9.5">+ old_values / new_values : NVARCHAR(MAX)</text>
      <text x="12" y="144" font-size="9.5">+ logged_at : DATETIME2(7) NOT NULL DEFAULT SYSDATETIME()</text>
    </g>
  </svg>"""
    return get_html_wrapper(svg, "Hình 7. Sơ đồ Vật lý Cơ sở Dữ liệu (Physical Database Diagram - PDM) trên Microsoft SQL Server 2022", 1520, 1080)


def render_all_diagrams():
    diagrams = [
        ("fig_use_case", generate_use_case_svg(), 1480, 980),
        ("fig_system_context", generate_system_context_svg(), 1400, 920),
        ("fig_system_architecture", generate_system_architecture_svg(), 1400, 950),
        ("fig_activity_workflow", generate_activity_workflow_svg(), 1400, 950),
        ("fig_conceptual_erd", generate_conceptual_erd_svg(), 1520, 1060),
        ("fig_logical_erd", generate_logical_schema_svg(), 1520, 1060),
        ("fig_physical_pdm", generate_physical_pdm_svg(), 1520, 1080),
    ]

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        for name, html_content, width, height in diagrams:
            html_path = OUTPUT_DIR_LATEX / f"{name}.html"
            png_latex_path = OUTPUT_DIR_LATEX / f"{name}.png"
            png_docs_path = OUTPUT_DIR_DOCS / f"{name}.png"

            with open(html_path, "w", encoding="utf-8") as f:
                f.write(html_content)

            page = browser.new_page(viewport={"width": width + 60, "height": height + 80}, device_scale_factor=2.5)
            page.goto(html_path.as_uri())
            page.wait_for_timeout(300)
            page.screenshot(path=str(png_latex_path), full_page=True)
            page.screenshot(path=str(png_docs_path), full_page=True)
            page.close()
            print(f"Rendered: {png_latex_path.name}")

        browser.close()
    print("All 7 diagrams generated with pixel-perfection!")


if __name__ == "__main__":
    render_all_diagrams()
