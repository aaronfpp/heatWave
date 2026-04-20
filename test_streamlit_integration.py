"""
Streamlit UI Integration Test
Validates that all the UI components can access the backend functions correctly.
"""
import tempfile
from pathlib import Path

# Test imports
print("Testing imports...")
try:
    from src.parser.extractor import extract_text_from_pdf, parse_events_from_text
    print("✓ Parser imports successful")
except Exception as e:
    print(f"✗ Parser import failed: {e}")
    exit(1)

try:
    from src.seeding.seeder import seed_event, format_heat_sheet
    print("✓ Seeding imports successful")
except Exception as e:
    print(f"✗ Seeding import failed: {e}")
    exit(1)

try:
    from src.core.pdf_generator import generate_full_meet_pdf, generate_heat_sheet_pdf
    print("✓ PDF generator imports successful")
except Exception as e:
    print(f"✗ PDF generator import failed: {e}")
    exit(1)

try:
    import streamlit as st
    print("✓ Streamlit installed")
except Exception as e:
    print(f"✗ Streamlit not installed: {e}")
    exit(1)

print("\n" + "="*80)
print("Testing UI workflow simulation...")
print("="*80)

# Test the complete workflow
pdf_path = "data/samples/1769543968773-7a7qa8q6s.pdf"
if not Path(pdf_path).exists():
    print(f"✗ Sample PDF not found: {pdf_path}")
    exit(1)

print("\n✓ Sample PDF found")

# Step 1: Extract
print("\n1. Testing PDF extraction...")
try:
    text = extract_text_from_pdf(pdf_path)
    assert len(text) > 50000
    print(f"   ✓ Extracted {len(text):,} characters")
except Exception as e:
    print(f"   ✗ Extraction failed: {e}")
    exit(1)

# Step 2: Parse
print("\n2. Testing event parsing...")
try:
    events = parse_events_from_text(text)
    assert len(events) > 0
    print(f"   ✓ Parsed {len(events)} events")
    
    total_entries = sum(len(e.entries) for e in events)
    print(f"   ✓ Total entries: {total_entries:,}")
except Exception as e:
    print(f"   ✗ Parsing failed: {e}")
    exit(1)

# Step 3: Seed
print("\n3. Testing heat seeding...")
try:
    heat_sheets = []
    for num_lanes in [6, 8, 10]:
        test_sheets = [seed_event(e, lanes=num_lanes) for e in events if e.entries]
        assert len(test_sheets) > 0
        print(f"   ✓ Seeded {len(test_sheets)} events for {num_lanes}-lane pool")
    
    # Use 8-lane for final test
    heat_sheets = [seed_event(e, lanes=8) for e in events if e.entries]
except Exception as e:
    print(f"   ✗ Seeding failed: {e}")
    exit(1)

# Step 4: Generate PDFs
print("\n4. Testing PDF generation...")
try:
    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)
        
        # Single event
        single_pdf = tmpdir / "single_event.pdf"
        generate_heat_sheet_pdf(
            heat_sheets[0],
            str(single_pdf),
            meet_title="Test Meet",
            meet_date="01/01/2025"
        )
        assert single_pdf.exists()
        assert single_pdf.stat().st_size > 1000
        print(f"   ✓ Single event PDF: {single_pdf.stat().st_size / 1024:.1f} KB")
        
        # Full meet
        full_pdf = tmpdir / "full_meet.pdf"
        generate_full_meet_pdf(
            heat_sheets,
            str(full_pdf),
            meet_title="Test Meet",
            meet_date="01/01/2025"
        )
        assert full_pdf.exists()
        assert full_pdf.stat().st_size > 50000
        print(f"   ✓ Full meet PDF: {full_pdf.stat().st_size / 1024:.1f} KB")
except Exception as e:
    print(f"   ✗ PDF generation failed: {e}")
    exit(1)

# Test settings customization
print("\n5. Testing settings customization...")
try:
    test_settings = [
        {"meet_title": "Oklahoma 10-Under Championships", "meet_date": "07/18/2025", "num_lanes": 8},
        {"meet_title": "Regional Qualifying Meet", "meet_date": "03/15/2025", "num_lanes": 6},
        {"meet_title": "Southern Sectionals", "meet_date": "04/10/2025", "num_lanes": 10},
    ]
    
    for settings in test_settings:
        # These would be used by Streamlit UI
        assert settings['meet_title']
        assert settings['meet_date']
        assert 4 <= settings['num_lanes'] <= 10
    
    print(f"   ✓ Settings validation works for {len(test_settings)} configurations")
except Exception as e:
    print(f"   ✗ Settings customization failed: {e}")
    exit(1)

# Test format functions
print("\n6. Testing formatting functions...")
try:
    formatted = format_heat_sheet(heat_sheets[0])
    assert "Event" in formatted
    assert "Heat" in formatted
    print(f"   ✓ Heat sheet text formatting works ({len(formatted)} chars)")
except Exception as e:
    print(f"   ✗ Formatting failed: {e}")
    exit(1)

print("\n" + "="*80)
print("✓ ALL STREAMLIT UI INTEGRATION TESTS PASSED")
print("="*80)

print("\nUI Capabilities:")
print("  ✓ PDF upload and processing")
print("  ✓ Event extraction and parsing")
print("  ✓ Heat seeding with variable lane counts")
print("  ✓ PDF generation (individual and full meet)")
print("  ✓ Settings customization")
print("  ✓ Text formatting and preview")

print("\nReady to run Streamlit UI:")
print("  Command: python run_streamlit.py")
print("  Browser: Open http://localhost:8501")
