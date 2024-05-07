from pathlib import Path
from PIL import Image
import pillow_avif

def convert_to_avif(input_path: Path, output_path: Path, quality=95):
  """
  Converts an image file to AVIF format using Pillow (if AVIF plugin is installed).

  Args:
      input_path: Pathlib object representing the input image file.
      output_path: Pathlib object representing the output AVIF file.
      quality: Integer between 0 (lossless) and 95 (lossy) representing AVIF quality (optional).
  """
  try:
    image = Image.open(str(input_path))
    output_path.parent.mkdir(parents=True, exist_ok=True)  # Create output directory if it doesn't exist
    image.save(str(output_path), "AVIF", quality=quality)
    print(f"Converted {input_path} from {image.format} to AVIF successfully!")
  except OSError:
    print(f"Error converting {input_path}. Make sure the file format is supported by Pillow.")


for src in [ p.resolve() for p in Path("./assets/").glob("**/*") if p.suffix in {'.webp', '.png'} ]:
    p = Path(src).resolve()
    convert_to_avif(p, p)