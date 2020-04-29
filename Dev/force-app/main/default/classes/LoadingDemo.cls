public class LoadingDemo {
    public void wait3Seconds() {
        Long startTime = DateTime.now().getTime();
        while(DateTime.now().getTime()-startTime<3000);
    }
}