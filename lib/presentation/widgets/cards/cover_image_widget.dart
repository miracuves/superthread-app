import 'package:flutter/material.dart';
import '../../../data/models/cover_image.dart';

class CoverImageWidget extends StatelessWidget {
  final CoverImage coverImage;
  final double height;
  const CoverImageWidget({Key? key, required this.coverImage, this.height = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: coverImage.emoji != null && coverImage.emoji!.isNotEmpty ? Colors.grey[100] : null,
        image: (coverImage.type == 'image' && coverImage.src != null) ? DecorationImage(image: NetworkImage(coverImage.src!), fit: BoxFit.cover) : null,
        gradient: (coverImage.type == 'gradient') ? LinearGradient(
          colors: [coverImage.color != null ? Color(int.parse(coverImage.color!.replaceAll('#', '0xFF'))) : Colors.grey, Colors.transparent],
        ) : null,
      ),
      child: (coverImage.emoji != null && coverImage.emoji!.isNotEmpty) ? Center(child: Text(coverImage.emoji!, style: TextStyle(fontSize: 80))) : null,
    );
  }
}
