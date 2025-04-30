import subprocess
import os
import argparse  # Import the argparse module

def convert_webp_to_mp4(webp_file):
    """Converts a WebP video file to an MP4 video file using FFmpeg.
    The output MP4 file will be saved in the same directory as the
    input WebP file, with the same name and a .mp4 extension.

    Args:
        webp_file (str): Path to the input WebP video file.

    Returns:
        int: 0 on success, non-zero on failure.
    """
    if not os.path.exists(webp_file):
        print(f"Error: WebP file not found at {webp_file}")
        return 1  # Indicate failure

    # Construct the output MP4 file path
    base_name, _ = os.path.splitext(webp_file)  # Get filename without extension
    mp4_file = base_name + ".mp4"

    # FFmpeg command to convert WebP to MP4
    command = [
        "ffmpeg",
        "-i", webp_file,
        "-c:v", "libx264",  # Use libx264 codec for MP4
        "-pix_fmt", "yuv420p",  # Pixel format for compatibility
        mp4_file
    ]

    try:
        # Run the FFmpeg command
        subprocess.run(command, check=True, capture_output=True)
        print(f"Successfully converted {webp_file} to {mp4_file}")
        return 0  # Indicate success
    except subprocess.CalledProcessError as e:
        # Handle errors during conversion
        print(f"Error converting {webp_file} to MP4:")
        print(e.stderr.decode("utf-8"))  # Print FFmpeg error message
        return e.returncode  # Return the error code from FFmpeg
    except FileNotFoundError:
        print("Error: FFmpeg not found. Please ensure FFmpeg is installed and in your system's PATH.")
        return 1
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return 1

if __name__ == "__main__":
    # Use argparse to get file paths from command line
    parser = argparse.ArgumentParser(description="Convert WebP video to MP4 using FFmpeg.")
    parser.add_argument("-s", "--source", required=True, help="Path to the source WebP video file.")

    args = parser.parse_args()  # Parse the arguments

    webp_video = args.source

    conversion_result = convert_webp_to_mp4(webp_video)
    if conversion_result == 0:
        print("Conversion was successful!")
    else:
        print("Conversion failed.")
