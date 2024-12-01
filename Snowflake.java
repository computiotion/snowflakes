import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

import java.sql.Timestamp;

public class Snowflake {
    /**
     * The timestamp after the Unix epoch that should be the basis for all dates. Defaults to 0.
     * 42 bits.
     */
    private Timestamp epoch = new Timestamp(0);
    /**
     * Internal process ID, in decimal.
     * 5 bits, max = 31.
     */
    private Integer pid = null;
    /**
     * Internal worker ID, in decimal.
     * 5 bits, max = 31.
     */
    private Integer worker = null;
    /**
     * Incremented for every generated ID on that process, in decimal.
     * 12 bits, max = 4095.
     */
    private Integer increment = null;

    @NotNull
    @Contract(" -> new")
    public static Snowflake fromDefaults() {
        return new Snowflake(0L, 0, 0, 0);
    }

    public Snowflake(Long epoch, Integer increment, Integer pid, Integer worker) {
        this.epoch = new Timestamp(0);
        this.increment = increment;
        this.pid = pid;
        this.worker = worker;
    }

    /**
     * @return the specified epoch
     */
    public Timestamp getEpoch() {
        return epoch;
    }

    public int getIncrement() {
        return increment;
    }

    public Snowflake setIncrement(Integer increment) {
        this.increment = increment;
        return this;
    }

    public int getWorker() {
        return worker;
    }

    public Snowflake setWorker(Integer worker) {
        this.worker = worker;
        return this;
    }

    public int getPid() {
        return pid;
    }

    public Snowflake setPid(Integer pid) {
        this.pid = pid;
        return this;
    }

    public Snowflake setEpoch(Timestamp epoch) {
        this.epoch = epoch;
        return this;
    }

    public String generate(Timestamp timestamp) {
        return String.valueOf(generateAsLong(timestamp));
    }

    public String generateAsLong(Timestamp timestamp) {
        if (epoch == null) epoch = new Timestamp(0);
        if (increment == null) increment = 0;
        if (pid == null) pid = 0;
        if (worker == null) worker = 0;

        long refTimestamp = timestamp.getTime() - epoch.getTime();

        String binaryTime = Long.toBinaryString(refTimestamp);
        String binaryWorker = Integer.toBinaryString(worker);
        String binaryPid = Integer.toBinaryString(pid);
        String binaryIncrement = Integer.toBinaryString(increment);

        return String.valueOf(Long.parseLong(binaryTime + binaryWorker + binaryPid + binaryIncrement, 2));
    }
}
