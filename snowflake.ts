export type Snowflake = string;

export interface SnowflakeOptions {
    /**
     * The timestamp after the Unix epoch that should be the basis for all dates. Defaults to 0.
     * 42 bits.
     */
    epoch: number,
    /**
     * Internal process ID, in decimal.
     * 5 bits, max = 31.
     */
    pid: number,
    /**
     * Internal worker ID, in decimal.
     * 5 bits, max = 31.
     */
    worker: number
    /**
     * Incremented for every generated ID on that process, in decimal.
     * 12 bits, max = 4095.
     */
    increment: number,
}

const defaultConfig: SnowflakeOptions = { epoch: 0, increment: 0, pid: 0, worker: 0 }

function decimalToBinary(decimal: number) {
    return (decimal >>> 0).toString(2);
}

export function generateSnowflake(time: number = Date.now(), config: Partial<SnowflakeOptions> = defaultConfig): Snowflake {
    if (config.epoch == null) config.epoch = defaultConfig.epoch;
    if (config.increment == null) config.increment = defaultConfig.increment;
    if (config.pid == null) config.pid = defaultConfig.pid;
    if (config.worker == null) config.worker = defaultConfig.worker;

    const timestamp = time - config.epoch;

    const binaryIncrement = decimalToBinary(config.increment % 4095).padStart(12, "0"); // only available using ESLINT 2017+
    const binaryTime = decimalToBinary(timestamp).padStart(42, "0"); // only available using ESLINT 2017+
    const binaryPid = decimalToBinary(config.pid).padStart(5, "0"); // only available using ESLINT 2017+
    const binaryWorker = decimalToBinary(config.worker).padStart(5, "0"); // only available using ESLINT 2017+

    return parseInt(binaryTime + binaryWorker + binaryPid + binaryIncrement, 2).toString();
}
