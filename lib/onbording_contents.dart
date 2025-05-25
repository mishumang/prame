class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Your journey to peace and mindfulness starts here.",
    image: "assets/images/image1.png",
    desc: "Discover techniques to relax your mind, control your breath, and find inner calm with our guided exercises.",
  ),
  OnboardingContents(
    title: "Explore Breathing Techniques",
    image: "assets/images/image2.png",
    desc:
    "Practice various breathing methods to manage stress, improve focus, and enhance your well-being.",
  ),
  OnboardingContents(
    title: "Tailored to help you relax and recharge.",
    image: "assets/images/image3.png",
    desc:
    "Choose exercises that fit your schedule and goals. Let's start this beautiful journey together.",
  ),
];
