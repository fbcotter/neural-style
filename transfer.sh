#! /bin/bash
# Script to run the style transfer
# Args:
# -p|--photo x : Path to input photo. Is photos/nick_k1.jpg by default
# -s|--style x : Path to input style. Is styles/starry.jpg by default
# -o|--outdir  : Output directory to put results in
# -k|--keep    : Flag to tell script to not reduce the image size before
#                processing

# Set default photo and style
PHOTO=photos/nick_k1.jpg
STYLE=styles/starry.jpg
OUTDIR=results/out
REDUCE=true

# Read in the arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--photo)
    PHOTO="$2"
    shift # past argument
    ;;
    -s|--style)
    STYLE="$2"
    shift # past argument
    ;;
	-o|--outdir)
	OUTDIR="$2"
	;;
	-k|--keep)
	REDUCE=false
	;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

# Make the out directory
mkdir -p $OUTDIR

# Crop the images unless specified not to
if [ "$REDUCE" = true ] ; then
    echo "Reducing..."
    echo "$OUTDIR"/in.jpg
    ffmpeg -y -i $PHOTO -vf scale=500:-1 "$OUTDIR"/in.jpg
    ffmpeg -y -i $STYLE -vf scale=500:-1 "$OUTDIR"/style.jpg
else
    cp $PHOTO "$OUTDIR"/in.jpg
    cp $STYLE "$OUTDIR"/style.jpg
fi

# Do the transfer
python3 neural_style.py --content "$OUTDIR/in.jpg" --styles "$OUTDIR"/style.jpg --output \
    $OUTDIR/out.jpg --checkpoint-output \
    $OUTDIR/out%04d.jpg --checkpoint-iterations 2

# Convert to a video
ffmpeg -y -pattern_type glob -i '$OUTDIR/out0*.jpg' -q:v 1 $OUTDIR/process.avi

